function [leo_satellites] = generate_leo(sc, leo_data,times)

  % Initialize empty lists
  leo_satellites = [];
  x = 1;

  % Loop through each row of leo_data
  for i = 1:size(leo_data, 1)
    % Extract satellite parameters
    semimajor_axis = leo_data(i, 1);
    eccentricity = leo_data(i, 2);
    inclination = leo_data(i, 3);
    raan = leo_data(i, 4);
    arg_of_perigee = leo_data(i, 5);
    true_anomaly = leo_data(i, 6);

    % Create satellite object
    current_satellite = leo_satellite(x,x+1,sc,semimajor_axis,eccentricity, ...
        inclination,raan,arg_of_perigee,true_anomaly,strcat('LEO',num2str(i)),i,times);

    x  = x + 2;

    % Add satellite to list
    leo_satellites = [leo_satellites; current_satellite];

    % Create gimbal objects with specific mounting locations UP
    gimbal_tran_up = gimbal(current_satellite.matlab_sat,...
        "MountingAngles",[0;180;0], ... % degrees
        "MountingLocation",[4;0;-5]);   % meters
    gimbal_rec_up = gimbal(current_satellite.matlab_sat, ...
        "MountingAngles",[0;180;0], ... % degrees
        "MountingLocation",[-4;0;-5]);   % meters

    tran_up = transmitter(gimbal_tran_up,...
        "MountingLocation",[0;0;1], ...           % meters
        "Frequency",30e9, ...                     % hertz
        "Power",300);                              % decibel watts
    gaussianAntenna(tran_up, ...
    "DishDiameter",0.5); 

    rec_up = receiver(gimbal_rec_up,...
        "MountingLocation",[0;0;1], ...      % meters
        "GainToNoiseTemperatureRatio",3, ... % decibels/Kelvin
        "RequiredEbNo",4);                   % decibels

    gaussianAntenna(rec_up, ...
    "DishDiameter",0.5); 



    % Create gimbal objects with specific mounting locations DOWN
    gimbal_tran_dwn = gimbal(current_satellite.matlab_sat,...
        "MountingAngles",[0;180;0], ... % degrees
        "MountingLocation",[4;0;5]);   % meters
    gimbal_rec_dwn = gimbal(current_satellite.matlab_sat, ...
        "MountingAngles",[0;180;0], ... % degrees
        "MountingLocation",[-4;0;5]);   % meters

    tran_dwn = transmitter(gimbal_tran_dwn,...
        "MountingLocation",[0;0;-1], ...           % meters
        "Frequency",30e9, ...                     % hertz
        "Power",300);                              % decibel watts
    gaussianAntenna(tran_dwn, ...
    "DishDiameter",0.5); 

    rec_dwn = receiver(gimbal_rec_dwn,...
        "MountingLocation",[0;0;-1], ...      % meters
        "GainToNoiseTemperatureRatio",3, ... % decibels/Kelvin
        "RequiredEbNo",4);                   % decibels

    gaussianAntenna(rec_dwn, ...
    "DishDiameter",0.5); 

    %{
       NOTE in leo:
        Gimbal 1 -> Up + tran
        Gimbal 2 -> Up + rec
        Gimbal 3 -> Down + tran
        Gimbal 4 -> Down + rec
    %}
  end
end