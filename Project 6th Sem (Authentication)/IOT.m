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
        sk
    end
    
    methods
        % Constructor
        function obj = IOT(sc,first_nmc,second_nmc,time_first,time_sec,network_manager_data)
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
        end

        function handle_authentication(obj,time,nmc,group_matrix_row,leo_satellites,ground_station)
            if time == obj.time_first
                for i=1:size(group_matrix_row,2)
                    if group_matrix_row(i) > 1
                        if obj.auth_token_set
                            obj.authentication_intra()
                        else
                            obj.auth_token_set = true;
                            obj.authentication_initial(nmc,leo_satellites(i),ground_station)
                        end
                    end
                end
            end
            if time == obj.time_second
                obj.authentication_inter()
            end
        end

        function authentication_initial(obj,nmc,leo_satellite,ground_station)
            disp("Initial")
            % User registers with NMC

            % send request with ID securely
            id = obj.platform.ID;
            processing_time1 = encrypt_decrypt_rsa(string(id));

            [obj.TID,obj.w_Ui,obj.public_key_K_Ui,obj.private_key_sigma_Ui] = nmc.user_registration(id);

            % Algorithm 1 : Access Request Generation

            obj.rand_b = Python_random(1000,9999999);
            obj.public_key_R_Ui = strings(1,2);
            [obj.public_key_R_Ui(1),obj.public_key_R_Ui(2)] = ECC_x_dot_P(obj.rand_b);

            ts1 = string(obj.sc.SimulationTime);
            hash = Hash_bits_to_Z(obj.public_key_R_Ui(1),obj.public_key_R_Ui(2),strcat(" ' ",ts1," ' "));
            M_Ui = strcat(obj.public_key_R_Ui(1),obj.public_key_R_Ui(2),ts1,string(obj.TID),obj.public_key_K_Ui(1),obj.public_key_K_Ui(2),string(obj.w_Ui));
            s_Ui = string(pyrun(strcat("ans=str(",obj.private_key_sigma_Ui,"-",hash,"*",obj.rand_b,")"),"ans"));

            access_request = strcat(M_Ui,s_Ui);

            % send access_request to leo satellite

            access_response = leo_satellite.access_response_generation(ground_station,obj);
            
        end

        function algorithm_3_sk_generation(obj,access_response,a)
            obj.sk = strings(1,2);
            [obj.sk(1),obj.sk(2)] = ECC_x_dot_P(a,obj.public_key_R_Ui(1),obj.public_key_R_Ui(2));

        end

        function authentication_intra(obj)
            disp("Intra")
            disp(obj.sc.SimulationTime)
        end

        function authentication_inter(obj)
            disp("Inter")
            disp(obj.sc.SimulationTime)
        end

    end
end
