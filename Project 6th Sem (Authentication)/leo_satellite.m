classdef leo_satellite < handle
    properties
        x
        y
        matlab_sat
        group_key
        network_manager
        sc
        ind
        times
        private_key_sigmaj
        public_key_Kj
        public_key_K_Gs_Le
        private_key_sigma_Gs_Le
        public_R_Le
        rand_c_Le
        ak % authentication key
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
            obj.ind = ind;
            obj.times = times;
            obj.private_key_sigmaj = -1;
            obj.public_key_Kj = -1;
            obj.public_key_K_Gs_Le = -1;
            obj.private_key_sigma_Gs_Le = -1;
            obj.rand_c_Le = -1;
            obj.public_R_Le = -1;

        end

        % form group_key after receiving coordinates_p
        function form_key(obj,new_group_key)
            obj.group_key = new_group_key;
            disp(strcat('Group key generated by LEO',num2str(obj.ind),":"))
            disp(obj.group_key)
        end

        function [access_response] = access_response_generation(obj,ground_station,IOT,access_request,nmc_public_key)
            % Algorithm 2 : Access Response Generation
                
            % verify access request
            split = string(pyrun(strcat("ans = [i for i in '", access_request , "'.split(',')]"),"ans"));
            
            R_Ui = strings(1,2);
            R_Ui(1) = split(1);
            R_Ui(2) = split(2);
            ts1 = split(3);
            TID = split(4);
            K_Ui = strings(1,2);
            K_Ui(1) = split(5);
            K_Ui(2) = split(6);
            w_Ui = split(7);
            s_Ui = split(8);

            X1 = strings(1,2);
            [X1(1),X1(2)] = ECC_x_dot_P(s_Ui);
            hash = Hash_bits_to_Z(R_Ui(1),R_Ui(2),ts1);
            X2 = strings(1,2);
            [X2(1),X2(2)] = ECC_x_dot_P(hash,R_Ui(1),R_Ui(2));
            hash = Hash_bits_to_Z(K_Ui(1),K_Ui(2),string(TID),string(w_Ui));
            X3 = strings(1,2);
            [X3(1),X3(2)] = ECC_x_dot_P(hash,nmc_public_key(1),nmc_public_key(2));

            sum_1 = strings(1,2);
            sum_2 = strings(1,2);

            [sum_1(1),sum_1(2)] = ECC_add_points(X1(1),X1(2),X2(1),X2(2));
            [sum_2(1),sum_2(2)] = ECC_add_points(K_Ui(1),K_Ui(2),X3(1),X3(2));

            disp(sum_1);
            disp(sum_2);

            if sum_1(1) ~= sum_2(1) || sum_1(2) ~= sum_2(2)
                disp("!!!!!!!!! ERROR OCCURED IN TRANSMISSION OF DATA !!!!!!!!!")
            end

            obj.rand_c_Le = Python_random(1000,9999999);
            obj.public_R_Le = strings(1,2);
            [obj.public_R_Le(1),obj.public_R_Le(2)] = ECC_x_dot_P(obj.rand_c_Le);
            ts2 = string(obj.sc.SimulationTime);

            hash = Hash_bits_to_Z(obj.public_R_Le(1),obj.public_R_Le(2),...
            ground_station.public_key_R_Gs(1),ground_station.public_key_R_Gs(2), ...
            ts2);

            % NOTE: OMITTED w_Gs_Le SINCE AUTHENTICATION OF LEO IS NOT OUR CONCERN 
            M_Le = strcat(obj.public_R_Le(1),",",obj.public_R_Le(2),",",...
            ground_station.public_key_R_Gs(1),",",ground_station.public_key_R_Gs(2),",",ts2,",", ...
            string(obj.matlab_sat.ID),",",string(ground_station.gs.ID),",",obj.public_key_K_Gs_Le(1),",", ...
            obj.public_key_K_Gs_Le(2),",",ground_station.public_key_Kj(1),",",ground_station.public_key_Kj(2));
            
            s_Le = string(pyrun(strcat("ans=str(",obj.private_key_sigma_Gs_Le,"-",hash,"*",obj.rand_c_Le,")"),"ans"));
            

            access_response = strcat(M_Le,",",s_Le);

            % send access_respnse to IOT device and ground station
            
            
            tic_processing = tic;
            Simulate_Data_Send(access_request,4);
            processing = toc(tic_processing);

            del_tic = tic;
            transmission_time = Transmission_Time(sym(states(obj.matlab_sat,obj.sc.SimulationTime,"CoordinateFrame","ecef")), ...
                sym(states(IOT.platform,obj.sc.SimulationTime,"CoordinateFrame","ecef")),processing);

            obj.times.initial_authentication_transmission(obj.times.initial_authentication_transmission_ind) = ... 
            obj.times.initial_authentication_transmission(obj.times.initial_authentication_transmission_ind) + transmission_time;
            
            del_time = toc(del_tic);

            obj.times.initial_authentication_processing(obj.times.initial_authentication_processing_ind) = ...
                obj.times.initial_authentication_processing(obj.times.initial_authentication_processing_ind) - del_time;

            ground_station.algorithm_3_sk_ak_ek_generation(access_response,IOT.rand_b,obj);

            IOT.algorithm_3_sk_ak_ek_generation(access_response,ground_station.rand_a,obj,nmc_public_key);

        end

        function hand_over_ticket_generate(obj,IOT)
            TGK = Hash_bits_to_Z(obj.group_key);
            Texp = "240"; % in seconds
            handover_ticket = Fernet_encrypt(strcat(string(IOT.platform.ID),",",IOT.ak(1),",",IOT.ak(2),",",Texp),TGK);

            % send handover_ticket ticket to User
            IOT.handover_ticket = handover_ticket;
        end

        function verify_handover_token_send_response_intra(obj,HO_req,IOT)
            TGK = Hash_bits_to_Z(obj.group_key);
            ID_IOT = HO_req{1,1}(1);
            ID_Leo = HO_req{1,2}(1);
            R_u = HO_req{1,3}(1);
            handover_ticket = HO_req{1,4}(1);
            ts1 = HO_req{1,5}(1);
            MAC_rec = HO_req{1,6}(1);
            
            % decrypt the handover_ticket

            original_message = Fernet_decrypt(handover_ticket,TGK);
            split = string(pyrun(strcat("ans = [i for i in '", original_message , "'.split(',')]"),"ans"));
            
            MAC_hash = Hash_bits_to_Z(split(2),split(3),ID_IOT, ...
                R_u,handover_ticket,ts1);

            if isequal(MAC_rec,MAC_hash)
                R_ns = Python_random(1000,9999999);
                
                MAC_ns = Hash_bits_to_Z(split(2),split(3),string(obj.matlab_sat.ID), ...
                    R_ns,string(obj.sc.SimulationTime));
                HO_res = {ID_IOT,string(obj.matlab_sat.ID),...
                    R_ns,string(obj.sc.SimulationTime),MAC_ns,"Satellite Handoff"};
                IOT.generate_new_ak_intra(HO_res,R_u,obj);

                % send response to IOT device
                request = strcat(string(ID_IOT),string(obj.matlab_sat.ID),...
                    R_ns,string(obj.sc.SimulationTime),MAC_ns,"Satellite Handoff");

                tic_processing = tic;
                Simulate_Data_Send(request,4);
                processing = toc(tic_processing);
                
                del_tic = tic;
          
                transmission_time = Transmission_Time(sym(states(obj.matlab_sat,obj.sc.SimulationTime,"CoordinateFrame","ecef")), ...
                sym(states(IOT.platform,obj.sc.SimulationTime,"CoordinateFrame","ecef")),processing);
    
                obj.times.intra_authentication_transmission(obj.times.intra_authentication_transmission_ind) = ...
                    obj.times.intra_authentication_transmission(obj.times.intra_authentication_transmission_ind) + transmission_time;
                del_time = toc(del_tic);

                obj.times.intra_authentication_processing(obj.times.intra_authentication_processing_ind) = ...
                    obj.times.intra_authentication_processing(obj.times.intra_authentication_processing_ind) - del_time;

                % increase index
                obj.times.intra_authentication_transmission_ind = obj.times.intra_authentication_transmission_ind + 1;
            
            end
        end

        function verify_handover_token_send_response_inter(obj,HO_req,IOT,prev_nmc,curr_nmc,geo_satellites,prev_nmc_leo)
        
            ID_IOT = HO_req{1,1}(1);
            R_u = HO_req{1,3}(1);
            handover_ticket = HO_req{1,4}(1);
            ts1 = HO_req{1,5}(1);
            MAC_rec = HO_req{1,6}(1);

            % request TGK from previous NMC by first sending request to 
            request_TGK_encrypt = Fernet_encrypt("send TGK",string(obj.group_key));

            tic_processing = tic;
            Simulate_Data_Send(request_TGK_encrypt,4);
            processing = toc(tic_processing);

            request_TGK_decrypt = Fernet_decrypt(request_TGK_encrypt,string(curr_nmc.group_key));

            % current NMC
            % c_LEO -> GEO -> p_NMC -> p_NMC_Leo -> c_NMC_Leo
            
            del_tic = tic;
            transmission_time_1 = Transmission_Time(sym(states(obj.matlab_sat,obj.sc.SimulationTime,"CoordinateFrame","ecef")), ...
                curr_nmc.ground_station.ecef,processing); % c_LEO -> c_GS

            transmission_time_2 = Transmission_Time(curr_nmc.ecef,sym(states(geo_satellites(curr_nmc.nearest_geo),obj.sc.SimulationTime,"CoordinateFrame","ecef")), ...
                processing); % c_NMC -> GEO
            transmission_time_3 = Transmission_Time(prev_nmc.ground_station.ecef,sym(states(geo_satellites(prev_nmc.nearest_geo),obj.sc.SimulationTime,"CoordinateFrame","ecef")), ...
                processing); % GEO -> p_GS
            transmission_time_4 = Transmission_Time(sym(states(prev_nmc_leo.matlab_sat,obj.sc.SimulationTime,"CoordinateFrame","ecef")), ...
                prev_nmc.ground_station.ecef,processing); % p_GS -> p_LEO
            transmission_time_5 = Transmission_Time(sym(states(prev_nmc_leo.matlab_sat,obj.sc.SimulationTime,"CoordinateFrame","ecef")),...
                sym(states(obj.matlab_sat,obj.sc.SimulationTime,"CoordinateFrame","ecef")),processing); % p_LEO -> c_LEO
            transmission_time_6 = Transmission_Time(curr_nmc.ecef, ...
                curr_nmc.ground_station.ecef,processing); % c_LEO -> c_GS


            obj.times.inter_authentication_transmission(obj.times.inter_authentication_transmission_ind) = ...
                obj.times.inter_authentication_transmission(obj.times.inter_authentication_transmission_ind) + transmission_time_4 + ...
                + transmission_time_3 + transmission_time_2 + transmission_time_1 + transmission_time_5 + transmission_time_6;
            
            del_time = toc(del_tic);
            
            obj.times.inter_authentication_processing(obj.times.inter_authentication_processing_ind) = ...
                obj.times.inter_authentication_processing(obj.times.inter_authentication_processing_ind) - del_time;


            TGK = prev_nmc.send_TGK_inter(IOT.group_count);

            if isequal(TGK,"-1")
                disp("Group Changed Do initial Authenticatino again")
            else
                % decrypt the handover_ticket

                original_message = Fernet_decrypt(handover_ticket,TGK);
                split = string(pyrun(strcat("ans = [i for i in '", original_message , "'.split(',')]"),"ans"));
                
                MAC_hash = Hash_bits_to_Z(split(2),split(3),ID_IOT, ...
                    R_u,handover_ticket,ts1);
    
                if isequal(MAC_rec,MAC_hash)
                    R_ns = Python_random(1000,9999999);
                    
                    MAC_ns = Hash_bits_to_Z(split(2),split(3),string(obj.matlab_sat.ID), ...
                        R_ns,string(obj.sc.SimulationTime));
                    HO_res = {ID_IOT,string(obj.matlab_sat.ID),...
                        R_ns,string(obj.sc.SimulationTime),MAC_ns,"Satellite Handoff"};
                    IOT.generate_new_ak_intra(HO_res,R_u,obj);

                    % send response to IOT device

                    request = strcat(string(ID_IOT),string(obj.matlab_sat.ID),...
                        R_ns,string(obj.sc.SimulationTime),MAC_ns,"Satellite Handoff");
                    
                    del_tic = tic;
            
                    tic_processing = tic;
                    Simulate_Data_Send(request,4);
                    processing = toc(tic_processing);
        
                    transmission_time = Transmission_Time(sym(states(obj.matlab_sat,obj.sc.SimulationTime,"CoordinateFrame","ecef")), ...
                    sym(states(IOT.platform,obj.sc.SimulationTime,"CoordinateFrame","ecef")),processing);
        
                    obj.times.inter_authentication_transmission(obj.times.inter_authentication_transmission_ind) = ...
                        obj.times.inter_authentication_transmission(obj.times.inter_authentication_transmission_ind) + transmission_time;
                    
                    del_time = toc(del_tic);

                    obj.times.inter_authentication_processing(obj.times.inter_authentication_processing_ind) = ...
                        obj.times.inter_authentication_processing(obj.times.inter_authentication_processing_ind) - del_time;


                    % increase index
                    obj.times.inter_authentication_transmission_ind = obj.times.inter_authentication_transmission_ind + 1;
                end

            end

        end 
            


    end
end




