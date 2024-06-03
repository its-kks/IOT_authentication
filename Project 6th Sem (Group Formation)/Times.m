classdef Times < handle
    %TIME time for processing and transmission
    
    properties
        ping_nm_to_leo_processing
        ping_nm_to_leo_transmission
        data_leo_nm_transmission
        data_leo_nm_processing
        data_nm_leo_processing
        date_nm_leo_transmission
        ping_ind
        data_leo_nm_ind
        data_nm_leo_ind_proc
        data_nm_leo_ind_trans
        key_retrieve_time
        ind_key_ret
    end
    
    methods
        function obj = Times(size)
            obj.ping_nm_to_leo_processing = zeros(1,size);
            obj.ping_nm_to_leo_transmission = zeros(1,size);
            obj.data_leo_nm_transmission = zeros(1,size);
            obj.data_leo_nm_processing = zeros(1,size);
            obj.data_nm_leo_processing = zeros(1,size);
            obj.date_nm_leo_transmission = zeros(1,size);
            obj.key_retrieve_time = zeros(1,size);
            obj.ping_ind = 1;
            obj.data_leo_nm_ind = 1;
            obj.data_nm_leo_ind_proc = 1;
            obj.data_nm_leo_ind_trans = 1;
            obj.ind_key_ret = 1;
        end
        function plot(obj)
            % Plotting the first scatter plot
            figure;
            scatter([1:obj.ping_ind-1], obj.ping_nm_to_leo_processing(1:obj.ping_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('Ping NM to LEO Processing');
        
            % Plotting the second scatter plot
            figure;
            scatter([1:obj.ping_ind-1], obj.ping_nm_to_leo_transmission(1:obj.ping_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('Ping NM to LEO Transmission');
        
            % Plotting the third scatter plot
            figure;
            scatter([1:obj.data_leo_nm_ind-1], obj.data_leo_nm_processing(1:obj.data_leo_nm_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('Data LEO NM Processing');
        
            % Plotting the fourth scatter plot
            figure;
            scatter([1:obj.data_leo_nm_ind-1], obj.data_leo_nm_transmission(1:obj.data_leo_nm_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('Data LEO NM Transmission');
        
            % Plotting the fifth scatter plot
            figure;
            scatter([1:obj.data_nm_leo_ind_proc-1], obj.data_nm_leo_processing(1:obj.data_nm_leo_ind_proc-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('Data NM to LEO Processing');
        
            % Plotting the sixth scatter plot
            figure;
            scatter([1:obj.data_nm_leo_ind_trans-1], obj.date_nm_leo_transmission(1:obj.data_nm_leo_ind_trans-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('Data NM to LEO Transmission');
            
            % Plotting the seventh scatter plot
            figure;
            scatter([1:obj.ind_key_ret-1], obj.key_retrieve_time(1:obj.ind_key_ret-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('Key retrieval time LEO');
        end

    end
end

