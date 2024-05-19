classdef Ground_station < handle
    properties
        gs
        rgb
        sc
        times
        private_key_sigmaj
        public_key_Kj
        public_key_R_Gs
        rand_a
        rand_r_Gs_Le
        sk
        ak
        ek
        ind
        ecef

    end
    
    methods
        % Constructor
        function obj = Ground_station(sc,nameGs,long,lat,rgb,times,ind)
            obj.gs = groundStation(sc, "Name", nameGs, "Longitude", long, "Latitude", lat); 
            obj.rgb = rgb;
            obj.gs.MarkerColor = rgb;
            obj.sc = sc;
            obj.private_key_sigmaj = -1;
            obj.public_key_Kj = -1;
            obj.times = times;
            obj.public_key_R_Gs = -1;
            obj.rand_a = "-1";
            obj.sk = -1;
            obj.ind = ind;
            obj.rand_r_Gs_Le = "-1";

            obj.ecef = lla2ecef([lat,long,0]);

        end

        function authenticate_leo(obj,leo_satellite)
            % AUTHENTICATION PHASE 3: Proxy Delegation Phase
            if isequal(obj.rand_a,"-1")
                obj.rand_a = Python_random(1000,9999999);
            end
            if isequal(obj.rand_r_Gs_Le,"-1")
                obj.rand_r_Gs_Le = Python_random(1000,9999999);
            end
            obj.public_key_R_Gs = strings(1,2);
            [obj.public_key_R_Gs(1),obj.public_key_R_Gs(2)] = ECC_x_dot_P(obj.rand_a);
            K_Gs_Le = strings(1,2);
            [K_Gs_Le(1),K_Gs_Le(2)] = ECC_x_dot_P(obj.rand_r_Gs_Le);
            leo_satellite.public_key_K_Gs_Le = K_Gs_Le;
            
            hash = Hash_bits_to_Z(K_Gs_Le(1),K_Gs_Le(2),leo_satellite.matlab_sat.ID,obj.public_key_R_Gs(1),obj.public_key_R_Gs(2));

            leo_satellite.private_key_sigma_Gs_Le = string(pyrun([strcat("ans = str(",obj.private_key_sigmaj,"*",hash,"+",obj.rand_r_Gs_Le,")")],"ans"));

        end

        function algorithm_3_sk_ak_ek_generation(obj,access_response,b,leo)
            obj.sk = strings(1,2);
            [obj.sk(1),obj.sk(2)] = ECC_x_dot_P(b,obj.public_key_R_Gs(1),obj.public_key_R_Gs(2));

            obj.ak = strings(1,2);
            obj.ek = strings(1,2);

            [obj.ak(1),obj.ak(2)] = key_generation_function(obj.sk(1),obj.sk(2));
            [obj.ek(1),obj.ek(2)] = key_generation_function(obj.ak(1),obj.ak(2));
            

            % send authentication key to leo satellites
            leo.ak = strings(1,2);
            leo.ak(1) = obj.ak(1);
            leo.ak(2) = obj.ak(2);
           
            tic_processing = tic;
            Simulate_Data_Send(strcat(obj.ak(1),obj.ak(2)),4);
            processing = toc(tic_processing);

            del_tic = tic;
            transmission_time = Transmission_Time(sym(lla2ecef([obj.gs.Latitude,obj.gs.Longitude,0])), ...
                sym(states(leo.matlab_sat,obj.sc.SimulationTime,"CoordinateFrame","ecef")),processing);

            obj.times.initial_authentication_transmission(obj.times.initial_authentication_transmission_ind) = ... 
            obj.times.initial_authentication_transmission(obj.times.initial_authentication_transmission_ind) + transmission_time;
            
            del_time = toc(del_tic);

            obj.times.initial_authentication_processing(obj.times.initial_authentication_processing_ind) = ...
                obj.times.initial_authentication_processing(obj.times.initial_authentication_processing_ind) - del_time;

        end

       
    end
end




