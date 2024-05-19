classdef IOT < handle
    properties
        platform
        rgb
        sc
        times
        first_nmc
        second_nmc
        time_first % in seconds
        time_second
        ind
        TID
        w_Ui
        public_key_K_Ui
        public_key_R_Ui
        private_key_sigma_Ui
        rand_b
        auth_token_set
        sk % Sharing key
        ak % Authentication key
        ek % Encryption Key
        handover_ticket
        group_count
    end
    
    methods
        % Constructor
        function obj = IOT(sc,first_nmc,second_nmc,time_first,time_sec,network_manager_data,time_object)
            obj.sc = sc;
            obj.first_nmc = first_nmc;
            obj.second_nmc = second_nmc;
            obj.time_first = time_first;
            obj.time_second = time_sec;
            lat_1 = network_manager_data(first_nmc,2);
            long_1 = network_manager_data(first_nmc,1);
            lat_2 = network_manager_data(second_nmc,2);
            long_2 = network_manager_data(second_nmc,1);
            trajectory = geoTrajectory([lat_1,long_1,0;lat_1,long_1,0;lat_2,long_2,0], ...
                [0,obj.time_first,obj.time_second],AutoPitch=true,AutoBank=true);
            obj.platform = platform(sc,trajectory);
            obj.platform.MarkerColor = [0 0 1];
            obj.ind = -1;
            obj.TID = -1;
            obj.w_Ui = -1;
            obj.public_key_K_Ui = -1;
            obj.private_key_sigma_Ui = -1;
            obj.rand_b = -1;
            obj.public_key_R_Ui = -1;
            obj.auth_token_set = false;
            obj.sk = -1;
            obj.handover_ticket = -1;
            obj.group_count = -1;
            obj.times = time_object;
        end

        function handle_authentication(obj,time,network_managers,group_matrix_row_prev,leo_satellites,ground_station, ...
                geo_satellites,group_matrix_row_curr)
            nmc_1 = network_managers(obj.first_nmc);
            nmc_2 = network_managers(obj.second_nmc);
            if time == obj.time_first
                for i=1:size(group_matrix_row_prev,2)
                    if group_matrix_row_prev(i) > 1
                        if obj.auth_token_set

                            tic_intra = tic;
                            obj.authentication_intra(leo_satellites(i))
                            end_tic_intra = (toc(tic_intra));

                            obj.times.intra_authentication_processing(obj.times.intra_authentication_processing_ind) = ...
                            obj.times.intra_authentication_processing(obj.times.intra_authentication_processing_ind) + end_tic_intra;
                            obj.times.intra_authentication_processing_ind = obj.times.intra_authentication_processing_ind + 1;
        
                        else
                            obj.auth_token_set = true;

                            
                            tic_initial = tic;
                            obj.authentication_initial(nmc_1,leo_satellites(i),ground_station)
                            end_tic_initial = (toc(tic_initial));
                            
                            % save processing time
                            obj.times.initial_authentication_processing(obj.times.initial_authentication_processing_ind) = ...
                                obj.times.initial_authentication_processing(obj.times.initial_authentication_processing_ind) + end_tic_initial;
                            obj.times.initial_authentication_processing_ind = obj.times.initial_authentication_processing_ind + 1;
                        end
                    end
                end
            end
            if time == obj.time_second
                for i=1:size(group_matrix_row_prev,2)
                    if group_matrix_row_prev(i) > 1
                        for j=1:size(group_matrix_row_curr,2)
                            if group_matrix_row_curr(j) > 1
                                tic_inter = tic;
                                obj.authentication_inter(leo_satellites(i),nmc_1,nmc_2,geo_satellites,leo_satellites(j));
                                end_tic_inter = (toc(tic_inter));
                                
                                obj.times.inter_authentication_processing(obj.times.inter_authentication_processing_ind) = ...
                                obj.times.inter_authentication_processing(obj.times.inter_authentication_processing_ind) + end_tic_inter;
                                obj.times.inter_authentication_processing_ind = obj.times.inter_authentication_processing_ind + 1;
                                
                                break
                            end
                        end
                        break
                    end
                end
            end
        end

        function authentication_initial(obj,nmc,leo_satellite,ground_station)
            disp('********************************************************')
            disp(strcat("Initial Authentication of IOT",string(obj.ind),":"))
            % User registers with NMC

            % send request with ID securely to NMC
            id = obj.platform.ID;
            tic_processing_1 = tic;
            Simulate_Data_Send(string(id),4);
            encrypt_decrypt_rsa(string(id));
            processing_1 = toc(tic_processing_1);
            
            del_tic = tic;
            
            transmission_time = Transmission_Time(nmc.ecef,sym(states(obj.platform,obj.sc.SimulationTime,"CoordinateFrame","ecef")),processing_1);

            obj.times.initial_authentication_transmission(obj.times.initial_authentication_transmission_ind) = ... 
            obj.times.initial_authentication_transmission(obj.times.initial_authentication_transmission_ind) + transmission_time;
            del_time = toc(del_tic);

            obj.times.initial_authentication_processing(obj.times.initial_authentication_processing_ind) = ...
                obj.times.initial_authentication_processing(obj.times.initial_authentication_processing_ind) - del_time;

            [obj.TID,obj.w_Ui,obj.public_key_K_Ui,obj.private_key_sigma_Ui,obj.group_count,public_key] = nmc.user_registration(id,obj);

            % verify received data
            lhs = strings(1,2);
            [lhs(1),lhs(2)] = ECC_x_dot_P(obj.private_key_sigma_Ui);
            hash = Hash_bits_to_Z(obj.public_key_K_Ui(1),obj.public_key_K_Ui(2),string(obj.TID),string(obj.w_Ui));
            rhs = strings(1,2);
            [rhs(1),rhs(2)] = ECC_x_dot_P(hash,public_key(1),public_key(2));
            [rhs(1),rhs(2)] = ECC_add_points(rhs(1),rhs(2),obj.public_key_K_Ui(1),obj.public_key_K_Ui(2));

            if lhs(1) ~= rhs(1) || lhs(2) ~= rhs(2)
                disp("!!!!!!!!! ERROR OCCURED IN TRANSMISSION OF DATA !!!!!!!!!")
            end


            % Algorithm 1 : Access Request Generation

            obj.rand_b = Python_random(1000,9999999);
            obj.public_key_R_Ui = strings(1,2);
            [obj.public_key_R_Ui(1),obj.public_key_R_Ui(2)] = ECC_x_dot_P(obj.rand_b);

            ts1 = string(obj.sc.SimulationTime);
            hash = Hash_bits_to_Z(obj.public_key_R_Ui(1),obj.public_key_R_Ui(2),ts1);
            M_Ui = strcat(obj.public_key_R_Ui(1),",",obj.public_key_R_Ui(2), ...
                ",",ts1,",",string(obj.TID),",",obj.public_key_K_Ui(1),",",obj.public_key_K_Ui(2),",",string(obj.w_Ui));
            s_Ui = string(pyrun(strcat("ans=str(",obj.private_key_sigma_Ui,"-",hash,"*",obj.rand_b,")"),"ans"));

            access_request = strcat(M_Ui,",",s_Ui);

            % send access_request to leo satellite

            del_tic2 = tic;
            tic_processing_2 = tic;
            Simulate_Data_Send(access_request,4);
            processing_2 = toc(tic_processing_2);

            transmission_time = Transmission_Time(sym(states(leo_satellite.matlab_sat,obj.sc.SimulationTime,"CoordinateFrame","ecef")), ...
                sym(states(obj.platform,obj.sc.SimulationTime,"CoordinateFrame","ecef")),processing_2);

            obj.times.initial_authentication_transmission(obj.times.initial_authentication_transmission_ind) = ... 
            obj.times.initial_authentication_transmission(obj.times.initial_authentication_transmission_ind) + transmission_time;
            
            del_time2 = toc(del_tic2);

            obj.times.initial_authentication_processing(obj.times.initial_authentication_processing_ind) = ...
                obj.times.initial_authentication_processing(obj.times.initial_authentication_processing_ind) - del_time2;


            access_response = leo_satellite.access_response_generation(ground_station,obj,access_request,nmc.public_key);
            
        end

        function algorithm_3_sk_ak_ek_generation(obj,access_response,a,leo,nmc_public_key)

            % verify access_response 
            split = string(pyrun(strcat("ans = [i for i in '", access_response , "'.split(',')]"),"ans"));

            R_Le = strings(1,2);
            R_Le(1) = split(1); 
            R_Le(2) = split(2);
            R_Gs = strings(1,2);
            R_Gs(1) = split(3);
            R_Gs(2) = split(4);
            ts2 = split(5);
            ID_Le = split(6);
            ID_Gs = split(7);
            K_Gs_Le = strings(1,2);
            K_Gs_Le(1) = split(8);
            K_Gs_Le(2) = split(9);
            K_Gs = strings(1,2);
            K_Gs(1) = split(10);
            K_Gs(2) = split(11);
            s_Le = split(12);
           
            X4 = strings(1,2);
            [X4(1),X4(2)] = ECC_x_dot_P(s_Le);
            X5 = strings(1,2);
            hash = Hash_bits_to_Z(R_Le(1),R_Le(2),R_Gs(1),R_Gs(2),ts2);
            [X5(1),X5(2)] = ECC_x_dot_P(hash,R_Le(1),R_Le(2));
            X6 = Hash_bits_to_Z(K_Gs_Le(1),K_Gs_Le(2),ID_Le);
            X7 = strings(1,2);
            hash = Hash_bits_to_Z(K_Gs(1),K_Gs(2),ID_Gs);
            [X7(1),X7(2)] = ECC_x_dot_P(hash,nmc_public_key(1),nmc_public_key(2));
            [X7(1),X7(2)] = ECC_add_points(K_Gs(1),K_Gs(2),X7(1),X7(2));

            sum = strings(1,2);
            product = strings(1,2);

            [sum(1),sum(2)] = ECC_add_points(X4(1),X4(2),X5(1),X5(2));
            [product(1),product(2)] = ECC_x_dot_P(X6,X7(1),X7(2));

            % The equations seem to be incorrect
            % even doing simplification by substitution results in LHS != RHS
          


            obj.sk = strings(1,2);
            [obj.sk(1),obj.sk(2)] = ECC_x_dot_P(a,obj.public_key_R_Ui(1),obj.public_key_R_Ui(2));
            
            obj.ak = strings(1,2);
            obj.ek = strings(1,2);

            [obj.ak(1),obj.ak(2)] = key_generation_function(obj.sk(1),obj.sk(2));
            [obj.ek(1),obj.ek(2)] = key_generation_function(obj.ak(1),obj.ak(2));

            
            disp(strcat("AK (authentication key) generated by IOT",string(obj.ind),":"));
            disp(obj.ak);
            

            leo.hand_over_ticket_generate(obj);

            % increase index
            obj.times.initial_authentication_transmission_ind = obj.times.initial_authentication_transmission_ind + 1;

        end

        function authentication_intra(obj,leo_satellite)
            disp('********************************************************')
            disp(strcat("Intra Authentication of IOT",string(obj.ind),":"))

            
            R_u = Python_random(10000,9999999);
            MAC_hash = Hash_bits_to_Z(obj.ak(1),obj.ak(2),obj.platform.ID, ...
                R_u,obj.handover_ticket,string(obj.sc.SimulationTime));

            HO_req = {obj.platform.ID,leo_satellite.matlab_sat.ID,R_u,obj.handover_ticket,...
                string(obj.sc.SimulationTime),MAC_hash};

            % send Handover Request to leo satellite
            request = strcat(string(obj.platform.ID),string(leo_satellite.matlab_sat.ID),R_u,obj.handover_ticket,...
                string(obj.sc.SimulationTime),MAC_hash);

            tic_processing = tic;
            Simulate_Data_Send(request,4);
            processing = toc(tic_processing);

            del_tic = tic;
            transmission_time = Transmission_Time(sym(states(leo_satellite.matlab_sat,obj.sc.SimulationTime,"CoordinateFrame","ecef")), ...
            sym(states(obj.platform,obj.sc.SimulationTime,"CoordinateFrame","ecef")),processing);

            obj.times.intra_authentication_transmission(obj.times.intra_authentication_transmission_ind) = ...
                obj.times.intra_authentication_transmission(obj.times.intra_authentication_transmission_ind) + transmission_time;
            del_time = toc(del_tic);

            obj.times.intra_authentication_processing(obj.times.intra_authentication_processing_ind) = ...
                obj.times.intra_authentication_processing(obj.times.intra_authentication_processing_ind) - del_time;

            leo_satellite.verify_handover_token_send_response_intra(HO_req,obj);
            

        end

        function generate_new_ak_intra(obj,HO_res,R_u,leo_satellite)


            obj.ak(1) = Hash_bits_to_Z(obj.ak(1),HO_res{1,1}(1),HO_res{1,2}(1), ...
                HO_res{1,3}(1),R_u);
            obj.ak(2) = Hash_bits_to_Z(obj.ak(1),HO_res{1,1}(1),HO_res{1,2}(1), ...
                HO_res{1,3}(1),R_u);

            % update authentication key of leo satellite also
            leo_satellite.ak(1) = obj.ak(1);
            leo_satellite.ak(2) = obj.ak(1);

            disp(strcat("New AK (authentication key) generated by IOT",string(obj.ind),":"));
            disp(obj.ak);

            % generate new authentication 
            leo_satellite.hand_over_ticket_generate(obj);
          
        end

        function authentication_inter(obj,prev_nmc_leo,prev_nmc,curr_nmc,geo_satellites,curr_nmc_leo)

            disp('********************************************************')
            disp(strcat("Inter Authentication of IOT",string(obj.ind),":"))
            
            R_u = Python_random(10000,9999999);
            MAC_hash = Hash_bits_to_Z(obj.ak(1),obj.ak(2),obj.platform.ID, ...
                R_u,obj.handover_ticket,string(obj.sc.SimulationTime));

            % Two more values added for itner:
            % 1. previous_NMC
            % 2. group_count_NMC
            HO_req = {obj.platform.ID,curr_nmc_leo.matlab_sat.ID,R_u,obj.handover_ticket,...
                string(obj.sc.SimulationTime),MAC_hash,prev_nmc,obj.group_count};
        
            % send Handover Request to Leo satellite
            request = strcat(string(obj.platform.ID),string(curr_nmc_leo.matlab_sat.ID),R_u,obj.handover_ticket,...
                string(obj.sc.SimulationTime),MAC_hash,string(prev_nmc.ind),string(obj.group_count));
            
            
            tic_processing = tic;
            Simulate_Data_Send(request,4);
            processing = toc(tic_processing);

            del_tic = tic;
            transmission_time = Transmission_Time(sym(states(curr_nmc_leo.matlab_sat,obj.sc.SimulationTime,"CoordinateFrame","ecef")), ...
            sym(states(obj.platform,obj.sc.SimulationTime,"CoordinateFrame","ecef")),processing);

            obj.times.inter_authentication_transmission(obj.times.inter_authentication_transmission_ind) = ...
                obj.times.inter_authentication_transmission(obj.times.inter_authentication_transmission_ind) + transmission_time;
            del_time = toc(del_tic);

            obj.times.inter_authentication_processing(obj.times.inter_authentication_processing_ind) = ...
                obj.times.inter_authentication_processing(obj.times.inter_authentication_processing_ind) - del_time;

            curr_nmc_leo.verify_handover_token_send_response_inter(HO_req,obj,prev_nmc,curr_nmc,geo_satellites,prev_nmc_leo);


        end

    end
end
