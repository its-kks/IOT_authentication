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
            figure;
            
            % Plotting the first bar graph
            subplot(2, 4, 1);
            plot([1:obj.ping_ind-2], obj.ping_nm_to_leo_processing(2:obj.ping_ind-1));
            xlabel('Index');
            ylabel('TIme');
            title('Ping NM to LEO Processing');
        
            % Plotting the second bar graph
            subplot(2, 4, 2);
            plot([1:obj.ping_ind-2], obj.ping_nm_to_leo_transmission(2:obj.ping_ind-1));
            xlabel('Index');
            ylabel('TIme');
            title('Ping NM to LEO Transmission');
        
            % Plotting the third bar graph
            subplot(2, 4, 3);
            plot([1:obj.data_leo_nm_ind-2], obj.data_leo_nm_processing(2:obj.data_leo_nm_ind-1));
            xlabel('Index');
            ylabel('TIme');
            title('Data LEO NM Processing');
        
            % Plotting the fourth bar graph
            subplot(2, 4, 4);
            plot([1:obj.data_leo_nm_ind-2], obj.data_leo_nm_transmission(2:obj.data_leo_nm_ind-1));
            xlabel('Index');
            ylabel('TIme');
            title('Data LEO NM Transmission');
        
            % Plotting the fifth bar graph
            subplot(2, 4, 5);
            plot([1:obj.data_nm_leo_ind_proc-2], obj.data_nm_leo_processing(2:obj.data_nm_leo_ind_proc-1));
            xlabel('Index');
            ylabel('TIme');
            title('Data NM to LEO Processing');

            % Plotting the sixth bar graph
            subplot(2, 4, 6);
            plot([1:obj.data_nm_leo_ind_trans-2], obj.date_nm_leo_transmission(2:obj.data_nm_leo_ind_trans-1));
            xlabel('Index');
            ylabel('TIme');
            title('Data NM to LEO Transmission');
            
            subplot(2, 4, 7);
            plot([1:obj.ind_key_ret-2],obj.key_retrieve_time(2:obj.ind_key_ret-1));
            xlabel('Index');
            ylabel('TIme');
            title('Key retrieval time LEO');

        end
    end
end

