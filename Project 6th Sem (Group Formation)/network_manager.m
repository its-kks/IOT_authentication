classdef network_manager < handle
    properties
        leo_xy
        gs
        group_change_info
        rgb
        count
        skip % how many times skip generation of new key
        group_key
        rand_values % will store random values provided by leo_satellites
        nearest_geo
        sc
        ecef
        ind
        times
    end
    
    methods
        % Constructor
        function obj = network_manager(sc,leo_xy,nameGs,long,lat,rgb,skip,geo_satellites,ind,times)
            obj.gs = groundStation(sc, "Name", nameGs, "Longitude", long, "Latitude", lat);
            obj.group_change_info = [0,0]; % first value indicates addition and second value 
            obj.leo_xy = leo_xy;
            obj.rgb = rgb;
            obj.count = 0;
            obj.skip = skip;
            obj.group_key = -1;
            obj.rand_values = [];
            obj.gs.MarkerColor = rgb;
            obj.sc = sc;

            geo_min_dis = realmax('double');
            obj.nearest_geo = -1;
            ecef_nm = lla2ecef([lat,long,0]);
            obj.ecef = ecef_nm;
            obj.ind = ind;
            obj.times = times;
            
            % this start time is same as the one mentioned at starting of Simulation_original.m file
            startTime = datetime(2024,2,18,11,23,0);


            % find the nearest geo satellite
            for i = 1:size(geo_satellites,1)
                % ecef coordinates of geo_satellite
                ecef_geo = states(geo_satellites(i),startTime,"CoordinateFrame","ecef");
                curr_dist = distance(ecef_geo,ecef_nm);

                if curr_dist < geo_min_dis
                    geo_min_dis = curr_dist;
                    obj.nearest_geo = i;
                end
            end
            
        end

        

        % obj is passed implicitly
        function [key,obj] = generate_key(obj, group_matrix_row, leo_satellites,geo_satellites)
            % reset previous values
            obj.rand_values = [];
            
            group_size = 0;
            leo_group_index = [];

            for i=1:size(leo_satellites,1)
                if group_matrix_row(i) > 1
                    group_size = group_size + 1;
                    leo_group_index = [leo_group_index ; i];
                  
                    % code : 999999999 for starting group key generation
                    [data_rec,snr,processing_time,transmission_time] = send_data_nm_geo_leo(999999,obj,geo_satellites,leo_satellites(i));
                    
                    obj.times.ping_nm_to_leo_processing(1,obj.times.ping_ind) = processing_time;

                    obj.times.ping_nm_to_leo_transmission(1,obj.times.ping_ind) = transmission_time;
                    obj.times.ping_ind = obj.times.ping_ind +1;

                    % initiate sending of data from leo for generation of group key4
                    leo_satellites(i).send_gkey_generate_data(obj,geo_satellites);
                    
                end
            end


            tic_nm = tic;
            
            % +1 for storing (0,group_key) 
            % the coordinates that will be used to make polynomial by network manager
            x_y_plus_rand = sym(zeros(group_size+1,2));

            % network manager has received data from leo and will generate polynomial
            for i=1:size(leo_group_index,1)
                % data integrity verification
                rec_id = obj.rand_values(i,2);
                rec_id = rec_id{1};
                rec_rand = obj.rand_values(i,3);
                rec_rand = rec_rand{1};
                rec_ts = obj.rand_values(i,4);
                rec_ts = rec_ts{1};
                rec_hash = obj.rand_values(i,1);
                rec_hash = rec_hash{1};

                saved_xy = obj.leo_xy(num2str(rec_id));

                %hash values
                original_val = [num2str(rec_rand) num2str(rec_id) num2str(saved_xy(1)) char(rec_ts)];
        
                % using SHA-256 hashing algorithm
                digester = java.security.MessageDigest.getInstance('SHA-256'); 
                data_bytes = uint8(original_val);
                hash_bytes = transpose(digester.digest(data_bytes));
                

                s1 = sum(rec_hash);
                s2 = sum(hash_bytes);
                if s1 ~= s2
                    % return explicitly and and start key generation proces again
                    obj.generate_key(group_matrix_row, leo_satellites,geo_satellites)
                    return
                else
                    x_y_plus_rand(i,1) = saved_xy(1);
                    x_y_plus_rand(i,2) = saved_xy(2) + rec_rand;

                end
                

            end
                
            new_group_key = randi([1,999]);
            obj.group_key = new_group_key;
            
            x_y_plus_rand(group_size+1,1) = 0;
            x_y_plus_rand(group_size+1,2) = new_group_key;

            % the network managers has found the coefficients of polynomial
            coefficients = find_coff_nm(x_y_plus_rand);
            
            %{
            disp(x_y_plus_rand)
            disp(obj.group_key)
            for i=1:size(coefficients,2)
                disp(coefficients{1,i})
            end
            %}

            disp('********************************************************')
            disp(['Random group key generated by NMC ', num2str(obj.ind),' : ',num2str(obj.group_key)]);


            % we want the coordinates_p must be of the form x/1 
            % lcm of denominators of 
            
            lcm_mul = 1;
            for i=1:size(coefficients,2)
                curr = coefficients{1,i};
                if curr.denominator~=1
                    lcm_mul = lcm(lcm_mul,curr.denominator);
                end
            end
            

            % the points that will be sent to leo satellites which will be used by them to generate group key

            coordinates_p_leo = sym(zeros(group_size+1,2));


            for i=2:size(coordinates_p_leo,1)
                new_x = randi([100,999])*lcm_mul;
                while ismember(new_x,coordinates_p_leo)
                    new_x = randi([1,9])*lcm_mul;
                end
                x_p = sym(new_x);
                first = coefficients{1,1};
                y_p = sym(first.numerator);

                for j=2:size(coefficients,2)
                    toAdd = x_p^(j-1);
                    curr = coefficients{1,j};
                    toAdd = toAdd/curr.denominator;
                    toAdd = toAdd*curr.numerator;
                    y_p = y_p + toAdd;
                end
                coordinates_p_leo(i,1) = x_p;
                coordinates_p_leo(i,2) = y_p;
            end


            % send the coordinates_p to each of the leo involved in group
            % we assume that the data is multicasted to all the LEO
            % satellites at once
            
            % since data has to be multicasted we are calculated
            % transmission time for one of the leo satellite since it will
            % be nearly same for each leo satellite
            ind = leo_group_index(1);
            transmission_time_tot = obj.send_coordinates_p_leo(leo_satellites(ind),coordinates_p_leo,geo_satellites);
            obj.times.date_nm_leo_transmission(1,obj.times.data_nm_leo_ind_trans) = transmission_time_tot;
            obj.times.data_nm_leo_ind_trans = obj.times.data_nm_leo_ind_trans + 1;
            

            processing_time_tot = toc(tic_nm);
            obj.times.data_nm_leo_processing(1,obj.times.data_nm_leo_ind_proc) = processing_time_tot;
            obj.times.data_nm_leo_ind_proc = obj.times.data_nm_leo_ind_proc + 1;
            
            % initiating group key generation by leo satellites
            for i=1:size(leo_group_index,1)
                ind = leo_group_index(i);
                leo_satellites(ind).form_key(coordinates_p_leo);

            end

        end

        function [transmission_time_tot] = send_coordinates_p_leo(obj,leo_satellite,coordinates_p, ...
                geo_satellites)
            digester =  java.security.MessageDigest.getInstance('SHA-256');
            coordinates_sum = zeros(1,size(coordinates_p,1));

            for i=1:size(coordinates_p,1)
                coordinates_sum(1,i) = coordinates_p(i,1) + coordinates_p(i,2); 
            end
            hash_bytes = digester.digest(coordinates_sum);

            % combining hash data
            hash_val = int32(1);
            count = 0;
            
            hash_val_arr = zeros(1,11+size(coordinates_p,1));
            ind = 1;

            for i=1:size(hash_bytes,1)
                if count == 3
                    count = 0;
                    hash_val_arr(ind) = hash_val;
                    ind = ind + 1;
                    hash_val = int32(1);
                end 
                hash_val = hash_val * 1000;
                hash_val = hash_val + int32(abs(hash_bytes(i)));
                count = count + 1;
            end
            
            
            for i=1:size(coordinates_p,1)
                hash_val_arr(i+11) = int32(coordinates_p(i,1) + coordinates_p(i,2))-1;
            end
            
            [data_rec,snr,processing_time,transmission_time] = send_data_nm_geo_leo(hash_val_arr(1),obj,geo_satellites,leo_satellite);
            
            transmission_time_tot = transmission_time + (size(hash_val_arr,2)-1)*processing_time;
            

        end
    end
end




