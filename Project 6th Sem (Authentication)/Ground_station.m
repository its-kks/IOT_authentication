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
        sk

    end
    
    methods
        % Constructor
        function obj = Ground_station(sc,nameGs,long,lat,rgb,times)
            obj.gs = groundStation(sc, "Name", nameGs, "Longitude", long, "Latitude", lat); 
            obj.rgb = rgb;
            obj.gs.MarkerColor = rgb;
            obj.sc = sc;
            obj.private_key_sigmaj = -1;
            obj.public_key_Kj = -1;
            obj.times = times;
            obj.public_key_R_Gs = -1;
            obj.rand_a = -1;
            obj.sk = -1;
            

        end

        function authenticate_leo(obj,leo_satellite)
            % AUTHENTICATION PHASE 3: Proxy Delegation Phase

            obj.rand_a = Python_random(1000,9999999);
            r_Gs_Le = Python_random(1000,9999999);
            obj.public_key_R_Gs = strings(1,2);
            [obj.public_key_R_Gs(1),obj.public_key_R_Gs(2)] = ECC_x_dot_P(obj.rand_a);
            K_Gs_Le = strings(1,2);
            [K_Gs_Le(1),K_Gs_Le(2)] = ECC_x_dot_P(r_Gs_Le);
            leo_satellite.public_key_K_Gs_Le = K_Gs_Le;
            
            hash = Hash_bits_to_Z(K_Gs_Le(1),K_Gs_Le(2),leo_satellite.matlab_sat.ID,obj.public_key_R_Gs(1),obj.public_key_R_Gs(2));

            leo_satellite.private_key_sigma_Gs_Le = string(pyrun([strcat("ans = str(",obj.private_key_sigmaj,"*",hash,"+",r_Gs_Le,")")],"ans"));

        end

        function algorithm_3_sk_generation(obj,access_response,b)
            obj.sk = strings(1,2);
            [obj.sk(1),obj.sk(2)] = ECC_x_dot_P(b,obj.public_key_R_Gs(1),obj.public_key_R_Gs(2));

        end

       
    end
end




