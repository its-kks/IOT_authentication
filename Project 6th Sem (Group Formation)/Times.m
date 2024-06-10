classdef Times < handle
    %TIME time for processing and transmission
    
    properties
        xiyi_to_NMC_proc;
        xiyi_to_NMC_packet;
        xiyi_to_NMC_trans_geo;
        xiyi_to_GEO_trans_leo;
        xiyi_hash_verify;
        polynomial_derivation_time;
        p_point_select;
        p_point_leo_proc;
        p_point_leo_packet;
        p_point_leo_trans_geo;
        p_point_geo_trans_nmc;
        gk_retrieval_time;
        leo_ind;
        nmc_ind;
        leo_ind_key;
    end
    
    methods
        function obj = Times(size)
            obj.xiyi_to_NMC_proc = zeros(1,size);
            obj.xiyi_to_NMC_packet = zeros(1,size);
            obj.xiyi_to_NMC_trans_geo = zeros(1,size);
            obj.xiyi_to_GEO_trans_leo = zeros(1,size);
            obj.xiyi_hash_verify = zeros(1,size);
            obj.gk_retrieval_time = zeros(1,size);
            obj.polynomial_derivation_time = zeros(1,size);
            obj.p_point_select = zeros(1,size);
            obj.p_point_leo_proc = zeros(1,size);
            obj.p_point_leo_trans_geo = zeros(1,size);
            obj.p_point_geo_trans_nmc = zeros(1,size);
            obj.p_point_leo_packet = zeros(1,size);
            obj.nmc_ind = 0;
            obj.leo_ind = 0;
            obj.leo_ind_key = 0;
        end
        function plot(obj)
            % Plotting the scatter plots
            figure;
            scatter([1:obj.leo_ind-1], obj.xiyi_to_NMC_proc(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('xiyi_to_NMC_proc');
            
            figure;
            scatter([1:obj.leo_ind-1], obj.xiyi_to_NMC_packet(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('xiyi_to_NMC_packet');
            
            figure;
            scatter([1:obj.leo_ind-1], obj.xiyi_to_NMC_trans_geo(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('xiyi_to_NMC_trans_geo');
            
            figure;
            scatter([1:obj.leo_ind-1], obj.xiyi_to_GEO_trans_leo(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('xiyi_to_GEO_trans_leo');
            
            figure;
            scatter([1:obj.leo_ind-1], obj.xiyi_hash_verify(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('xiyi_hash_verify');
            
            figure;
            scatter([1:obj.leo_ind-1], obj.polynomial_derivation_time(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('polynomial_derivation_time');
            
            figure;
            scatter([1:obj.leo_ind-1], obj.p_point_select(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('p_point_select');
            
            figure;
            scatter([1:obj.leo_ind-1], obj.p_point_leo_proc(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('p_point_leo_proc');
            
            figure;
            scatter([1:obj.leo_ind-1], obj.p_point_leo_packet(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('p_point_leo_packet');
            
            figure;
            scatter([1:obj.leo_ind-1], obj.p_point_leo_trans_geo(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('p_point_leo_trans_geo');
            
            figure;
            scatter([1:obj.leo_ind-1], obj.p_point_geo_trans_nmc(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('p_point_geo_trans_nmc');
            
            figure;
            scatter([1:obj.leo_ind-1], obj.gk_retrieval_time(1:obj.leo_ind-1), 'filled');
            xlabel('Index');
            ylabel('Time');
            title('gk_retrieval_time');
        end

        function find_average(obj)
            % Average time to process [hash_val,ID,random_val,time_stamp]
            disp("Average time to process [hash_val,ID,random_val,time_stamp] by LEO")
            disp(sum(obj.xiyi_to_NMC_proc)/obj.leo_ind);
            
            % Average time for other processes
            disp("Average time for packet generation [hash_val,ID,random_val,time_stamp] by LEO")
            disp(sum(obj.xiyi_to_NMC_packet)/obj.leo_ind);
            
            disp("Average time to transmit packet from LEO to GEO")
            disp(sum(obj.xiyi_to_GEO_trans_leo)/obj.leo_ind);

            disp("Average time to transmit packet from GEO to NMC")
            disp(sum(obj.xiyi_to_NMC_trans_geo)/obj.leo_ind);
            
            disp("Average time to verify hash value received by NMC from LEO")
            disp(sum(obj.xiyi_hash_verify)/obj.nmc_ind);
            
            disp("Average time for derivation of polynomial by NMC")
            disp(sum(obj.polynomial_derivation_time)/obj.nmc_ind);
            
            disp("Average time to select random points on polynomial by NMC")
            disp(sum(obj.p_point_select)/obj.nmc_ind);
            
            disp("Average time to process [hash_val, p1, p2 ..., pn] by NMC")
            disp(sum(obj.p_point_leo_proc)/obj.nmc_ind);
            
            disp("Average time for packet generation [hash_val, p1, p2 ..., pn] by NMC")
            disp(sum(obj.p_point_leo_packet)/obj.nmc_ind);
            
            disp("Average time for packet transmission from NMC to GEO")
            disp(sum(obj.p_point_geo_trans_nmc)/obj.nmc_ind);
            
            disp("Average time to transmit packet transmission from GEO to LEO")
            disp(sum(obj.p_point_leo_trans_geo)/obj.nmc_ind);
            
            disp("Average time for GK retrieval by LEO")
            disp(sum(obj.gk_retrieval_time)/obj.leo_ind);
        end

    end
end
