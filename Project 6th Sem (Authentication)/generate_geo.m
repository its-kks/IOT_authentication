function [geo_satellites] = generate_geo(sc, geo_data)

  % Initialize empty lists
  geo_satellites = [];

  % Loop through each row of geo_data
  for i = 1:size(geo_data, 1)
    % Extract satellite parameters
    semimajor_axis = geo_data(i, 1);
    eccentricity = geo_data(i, 2);
    inclination = geo_data(i, 3);
    raan = geo_data(i, 4);
    arg_of_perigee = geo_data(i, 5);
    true_anomaly = geo_data(i, 6);

    % Create satellite object
    current_satellite = satellite(sc, semimajor_axis, eccentricity, ...
        inclination, raan, arg_of_perigee, true_anomaly,"Name",strcat('GEO',num2str(i)));
    % Add satellite to list
    geo_satellites = [geo_satellites; current_satellite];

    % Create gimbal objects with specific mounting locations
    gimbal_tran = gimbal(current_satellite, "MountingLocation", [0; 1; 2]);
    gimbal_rec = gimbal(current_satellite, "MountingLocation", [0; -1; 2]);

    tran = transmitter(gimbal_tran,...
        "MountingLocation",[0;0;1], ...   % meters
        "Frequency",30e9, ...             % hertz
        "Power",600);                     % decibel watts
    gaussianAntenna(tran, ...
    "DishDiameter",0.5); 

    rec = receiver(gimbal_rec,...
        "MountingLocation",[0;0;1], ...      % meters
        "GainToNoiseTemperatureRatio",3, ... % decibels/Kelvin
        "RequiredEbNo",4);                   % decibels

    gaussianAntenna(rec, ...
    "DishDiameter",0.5); 

   
  end
end