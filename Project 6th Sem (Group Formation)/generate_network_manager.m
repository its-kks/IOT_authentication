function [network_managers] = generate_network_manager(sc, network_manager_data,leo_xy,geo_satellites,times) 
    % Initialize an empty array
    network_managers = [];
   
    % Loop through ground station data
    for i = 1:size(network_manager_data, 1)
        current_nm = network_manager(sc,leo_xy,strcat('NMC',num2str(i)), ...
            network_manager_data(i,1), ...
            network_manager_data(i,2), ...
            [network_manager_data(i,3),network_manager_data(i,4),network_manager_data(i,5)], ...
            0,geo_satellites,i,times);
        
       
        network_managers = [network_managers; current_nm];

        % Create gimbal objects with specific mounting locations
        gimbal_tran = gimbal(current_nm.gs,...
            "MountingAngles",[0;180;0], ... % degrees
            "MountingLocation",[4;0;-5]);   % meters
        gimbal_rec = gimbal(current_nm.gs, ...
            "MountingAngles",[0;180;0], ... % degrees
            "MountingLocation",[-4;0;-5]);   % meters
    
        tran = transmitter(gimbal_tran,...
            "MountingLocation",[0;0;1], ...           % meters
            "Frequency",30e9, ...                     % hertz
            "Power",300);                              % decibel watts
        gaussianAntenna(tran, ...
        "DishDiameter",2); 

    
        rec = receiver(gimbal_rec,...
            "MountingLocation",[0;0;1], ...        % meters
            "GainToNoiseTemperatureRatio",3, ...   % decibels/Kelvin
            "RequiredEbNo",1); 

        gaussianAntenna(rec, ...
        "DishDiameter",2); 


    end
end
