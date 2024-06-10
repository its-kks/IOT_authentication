function [time] = Transmission_Time(ecef_1,ecef_2,processing_time)
    
    % ecef = sym(states(entity_2,sc.SimulationTime,"CoordinateFrame","ecef"));

    dis = distance(ecef_1,ecef_2);
    time = sym(dis/300000000);
    time = time + processing_time;
end

