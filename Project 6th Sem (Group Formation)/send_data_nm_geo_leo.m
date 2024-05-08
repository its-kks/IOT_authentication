function [data_rec,snr,processing_time,transmission_time] = send_data_nm_geo_leo(data,network_manager,geo_satellites,leo_satellite)
%SEND_DATA_NM_GEO it modulates data at the nm send it to geo where it is not demodulated
    
    % start timer
    
    start_tic_send = tic;
    
    data_rec = -1;
    count = sym(0);

    % retransmission of data if incorrect data received
    while data_rec == -1
        % add crc and conver to binary 
        [crc_data_tran, data_bits] = crc32_encode(data);
        
        % modulate and demodulate the signal
        [crc_data_received,snr] = modulate_demodulate(crc_data_tran);
    
    
        % crc decode
        data_rec = crc32_decode(crc_data_received);

        count = count + 1;
    end


    % stop timer
    end_tic_send = (toc(start_tic_send));
    processing_time = (end_tic_send)/count;

    % calculate transmission time

    ecef_geo = sym(states(geo_satellites(network_manager.nearest_geo),network_manager.sc.SimulationTime,"CoordinateFrame","ecef"));
    ecef_leo = sym(states(leo_satellite.matlab_sat,network_manager.sc.SimulationTime,"CoordinateFrame","ecef"));
    ecef_nm = sym(network_manager.ecef);

    tot_dist = sym(distance(ecef_nm,ecef_geo) + distance(ecef_leo,ecef_geo));

    transmission_time = sym(tot_dist/300000000);
end

