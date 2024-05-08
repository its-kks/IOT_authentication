clc,clearvars


% to return runtime of simulation
start_sim = tic;

startTime = datetime(2024,2,18,11,23,0);
stopTime = startTime + hours(0.6);
sampleTime = 60; %sample time is in seconds

sc = satelliteScenario(startTime,stopTime,sampleTime);

%{ 
preventing autosimulate so that we can control the simulation and also
access the current simulation time 
%}

sc.AutoSimulate = false;
currTime = startTime; % for running the simulation

% load leo_data stored in leo_data variable
load('leo_data.mat');

% load geo data stored in geo_data variable
load('geo_data.mat')

% load network manager data in network_manager_data variable

load('network_manager_data.mat')

time_object = Times(500);

leo_satellites = generate_leo(sc,leo_data,time_object);

geo_satellites = generate_geo(sc,geo_data);


% fill x,y for each leo to be stored in NMC

leo_xy = containers.Map;
for i = 1:size(leo_satellites,1)
    leo_xy(num2str(leo_satellites(i).matlab_sat.ID)) = [leo_satellites(i).x, leo_satellites(i).y];
end

network_managers = generate_network_manager(sc,network_manager_data, ...
    leo_xy,geo_satellites,time_object);


% link network managers to leo satellites
access_list = cell(size(leo_satellites,1),size(network_managers,1));

for i=1:size(leo_satellites,1)
    for j=1:size(network_managers,1)
        access_list{i, j} = access(leo_satellites(i).matlab_sat, ...
            network_managers(j).gs);
    end
end

% it detects if a new network manager is in range of leo satellite
detect_change_nm_access = zeros(size(leo_satellites,1),size(network_managers,1));

% Matrix to determine which satellite is linked with which network manager
% 0 -> satellite not a part
% >1 -> satellite is a part and is added recently
% -1 -> satellite is deleted recently
group_matrix = zeros(size(network_managers,1),size(leo_satellites,1));



% The loop that keep moving the simulation forward

while sc.SimulationTime ~= sc.StopTime
    sc.advance();
    drawnow;
    disp(sc.SimulationTime)
    

    for leo_in=1:size(leo_satellites,1)
        for nm_in=1:size(network_managers,1)
            % Checking if all group satellites are in range
            if group_matrix(nm_in,leo_in) ~= 0
                curr_duration = accessIntervals(access_list{leo_in,nm_in}).Duration(detect_change_nm_access(leo_in,nm_in));
                if group_matrix(nm_in,leo_in) == curr_duration
                    % Satellite has gone out of range
                    group_matrix(nm_in,leo_in) = -1;
                    % mark group_change_info for satellite removal
                    network_managers(nm_in).group_change_info(2) = 1;
                    % mark that leo is not part of any group currently
                    leo_satellites(leo_in).network_manager = -1;
                else
                    % Satellite is still in range
                    group_matrix(nm_in,leo_in) = curr_duration;
                end
            end
            if detect_change_nm_access(leo_in,nm_in) ~= size(accessIntervals(access_list{leo_in,nm_in}),1)
                detect_change_nm_access(leo_in,nm_in) = detect_change_nm_access(leo_in,nm_in) + 1;

                % change color of satellite same as its network manager
                % leo_satellites(leo_in).matlab_sat.MarkerColor = network_managers(nm_in).gs.MarkerColor;
                
                % since color is not changing dyanamically it is fixed to red
                leo_satellites(leo_in).matlab_sat.MarkerColor = [1,0,1];

                % Changing Group Information for Leo Satellite and NMC

                % STEP 1: remove the satellite from its previous network
                % manager group if it was previously part of one and not
                % yet removed

                prev_network_manager = leo_satellites(leo_in).network_manager;
                
                if prev_network_manager ~= -1
                    group_matrix(prev_network_manager,leo_in) = -1;
                end

                % STEP 2: mark group_change_info for satellite removal
                if prev_network_manager ~= -1
                    network_managers(prev_network_manager).group_change_info(2) = 1;
          
                end

                % STEP 3: add the satellite to its new network manager group

                new_network_manager = nm_in;
                
                group_matrix(new_network_manager,leo_in) = accessIntervals(access_list{leo_in,nm_in}).Duration(detect_change_nm_access(leo_in,nm_in));

                leo_satellites(leo_in).network_manager = new_network_manager;

                % STEP 4: mark group_change_info for satellite addition

                network_managers(new_network_manager).group_change_info(1) = 1;
                

            end 
        end
    end
    % Here we will handle new group key generation
    for i=1:size(network_managers,1)
        if network_managers(i).group_change_info(1) == 1
            % addition detected
            
            % unmark group_change_info
            network_managers(i).group_change_info(1) = 0;
            network_managers(i).group_change_info(2) = 0;
            
            % reset group_matrix
            satellite_count = 0;
            for j=1:size(leo_satellites,1)
                if group_matrix(i,j) > 1 % satellite of current group
                    satellite_count = satellite_count + 1;
                end
                if group_matrix(i,j) == -1 % this satellite was deleted
                    group_matrix(i,j) = 0;
                    satellite_count = satellite_count - 1;
                end
            end
            % generate new group key for all the satellites
            if satellite_count > 1
                network_managers(i).generate_key(group_matrix(i,:),leo_satellites,geo_satellites);
            end

        elseif network_managers(i).group_change_info(2) == 1
            % deletion detected
            
            % unmark group_change_info
            network_managers(i).group_change_info(2) = 0;

            satellite_count = 0;
            % reset group_matrix
            for j=1:size(leo_satellites,1)
                if group_matrix(i,j) == -1 % this satellite was deleted
                    group_matrix(i,j) = 0;
                    satellite_count = satellite_count - 1;
                end
                if group_matrix(i,j) > 1
                    satellite_count = satellite_count + 1;
                end
            end

            % generate key with all the satellites left with it
            if satellite_count > 1
                network_managers(i).generate_key(group_matrix(i,:),leo_satellites,geo_satellites);
            end
           
        end
    end
    
end

play(sc);

simulation_runtime = toc(start_sim);

fprintf('Execution time: %.6f seconds\n', simulation_runtime);