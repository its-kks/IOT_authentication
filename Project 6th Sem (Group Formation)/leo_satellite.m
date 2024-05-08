classdef leo_satellite < handle
    properties
        x
        y
        matlab_sat
        group_key
        network_manager
        sc
        random
        coordinates
        ind
        times
    end
    
    methods
        % Constructor
        function obj = leo_satellite(x,y,sc,semiMajorAxis,eccentricity,...
                inclination, ...
                RAAN, ...
                argumentOfPerigee, ...
                trueAnomaly, ...
                nameSat,ind,times)
            obj.x = x;
            obj.y = y;
            obj.matlab_sat = satellite(sc, ...
                    semiMajorAxis, ...
                    eccentricity, ...
                    inclination, ...
                    RAAN, ...
                    argumentOfPerigee, ...
                    trueAnomaly, ...
                    "Name",nameSat, ...
                    "OrbitPropagator","two-body-keplerian");
            obj.group_key = -1;
            obj.network_manager = -1;
            obj.sc = sc;
            obj.random = -1;
            obj.coordinates = cell(1,1);
            obj.ind = ind;
            obj.times = times;

        end
        % Group key agreement request
        function  send_gkey_generate_data(obj,network_manager,geo_satellites)
            random_val = randi([10,99]);
            obj.random = random_val;
            time_stamp = obj.sc.SimulationTime;

            tic_leo1 = tic;
            
            %hash values
            original_val = [num2str(random_val) num2str(obj.matlab_sat.ID) num2str(obj.x) char(time_stamp)];

            % using SHA-256 hashing algorithm
            digester = java.security.MessageDigest.getInstance('SHA-256'); 
            data_bytes = uint8(original_val);
            hash_bytes = digester.digest(data_bytes);


            % combining hash data
            hash_val = int32(1);
            count = 0;
            
            hash_val_arr = zeros(1,14);
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
            

            % 11 for hash value 1 for id 1 for x and 1 for time

            %append time , id, random_val

            hash_val_arr(ind) = obj.matlab_sat.ID;
            hash_val_arr(ind+1) = random_val;
            hash_val_arr(ind+2) = str2double(datestr(now, 'DDMMYYHH'));

            
            % total transmission time = Trans + (n-1)Tprocess
            transmission_time_tot = 0;
            for i=1:14
                [data_rec,snr,processing_time,transmission_time] = send_data_nm_geo_leo(hash_val_arr(i),network_manager,geo_satellites,obj);
                if i==1
                    transmission_time_tot = sym(transmission_time + 13*processing_time);
                end
            end

            
            message_to_nm = {transpose(hash_bytes),obj.matlab_sat.ID,random_val,time_stamp};
            network_manager.rand_values = vertcat(network_manager.rand_values,message_to_nm);
            
            
            processing_time_tot = (toc(tic_leo1));

            % adding transmission and processing time

            obj.times.data_leo_nm_transmission(1, obj.times.data_leo_nm_ind) = transmission_time_tot;
            obj.times.data_leo_nm_processing(1, obj.times.data_leo_nm_ind) = processing_time_tot;

            obj.times.data_leo_nm_ind = obj.times.data_leo_nm_ind + 1;

            

        end
        % form group_key after receiving coordinates_p
        function form_key(obj,coordinates_p)

            tic_leo2 = tic;
            coordinates_p(1,1) = obj.x;
            coordinates_p(1,2) = obj.y + obj.random;
            obj.coordinates = coordinates_p;
            coefficients = find_coff_nm(coordinates_p);
            first = coefficients{1,1};

            obj.group_key = first.numerator;
            
            processing_time = (toc(tic_leo2));

            obj.times.key_retrieve_time(1,obj.times.ind_key_ret) = processing_time;
            obj.times.ind_key_ret = obj.times.ind_key_ret + 1;

            disp(['Group key generated by LEO ',num2str(obj.ind)])
            disp(obj.group_key)
            
        end
        
        
    end
end




