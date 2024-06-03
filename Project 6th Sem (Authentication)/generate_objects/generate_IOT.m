function [IOTs] = generate_IOT(sc,IOT_data,network_manager_data,network_managers,time_object)
    n = size(IOT_data,1);
    IOTs = IOT.empty(n,0);
    for i=1:n
        IOTs(i) = IOT(sc,IOT_data(i,1),IOT_data(i,2),IOT_data(i,3), ...
            IOT_data(i,4),network_manager_data,time_object);
        IOTs(i).ind = i;
        network_managers(IOT_data(i,1)).IOT_controller = i;
    end
end

