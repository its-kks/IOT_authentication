classdef Times < handle
    %TIME time for processing and transmission
    
    properties
        initial_authentication_transmission
        initial_authentication_processing
        intra_authentication_transmission
        intra_authentication_processing
        inter_authentication_transmission
        inter_authentication_processing
        initial_authentication_processing_ind
        initial_authentication_transmission_ind
        intra_authentication_processing_ind
        intra_authentication_transmission_ind
        inter_authentication_processing_ind
        inter_authentication_transmission_ind
        
    end
    
    methods
        function obj = Times(size)
            obj.initial_authentication_transmission = zeros(1,size);
            obj.initial_authentication_processing = zeros(1,size);
            obj.intra_authentication_transmission = zeros(1,size);
            obj.intra_authentication_processing = zeros(1,size);
            obj.inter_authentication_transmission = zeros(1,size);
            obj.inter_authentication_processing = zeros(1,size);
            obj.initial_authentication_processing_ind = 1;
            obj.initial_authentication_transmission_ind = 1;
            obj.intra_authentication_processing_ind = 1;
            obj.intra_authentication_transmission_ind = 1;
            obj.inter_authentication_processing_ind = 1;
            obj.inter_authentication_transmission_ind = 1;
        end
        
        function plot(obj)
            % Plot initial_authentication_transmission
            figure;
            scatter(1:length(obj.initial_authentication_transmission), obj.initial_authentication_transmission, 'filled');
            xlim([0, length(obj.initial_authentication_transmission)]);  % Set x-axis limits
            title('Initial Authentication Transmission');
            xlabel('Index');
            ylabel('Second');
            
            % Plot initial_authentication_processing
            figure;
            scatter(1:length(obj.initial_authentication_processing), obj.initial_authentication_processing, 'filled');
            xlim([0, length(obj.initial_authentication_processing)]);  % Set x-axis limits
            title('Initial Authentication Processing');
            xlabel('Index');
            ylabel('Second');
            
            % Plot sum of initial_authentication_transmission and initial_authentication_processing
            figure;
            scatter(1:length(obj.initial_authentication_transmission), obj.initial_authentication_transmission + obj.initial_authentication_processing, 'filled');
            xlim([0, length(obj.initial_authentication_transmission)]);  % Set x-axis limits
            title('Total Initial Authentication');
            xlabel('Index');
            ylabel('Second');
            
            % Plot intra_authentication_transmission
            figure;
            scatter(1:length(obj.intra_authentication_transmission), obj.intra_authentication_transmission, 'filled');
            xlim([0, length(obj.intra_authentication_transmission)]);  % Set x-axis limits
            title('Intra Authentication Transmission');
            xlabel('Index');
            ylabel('Second');
            
            % Plot intra_authentication_processing
            figure;
            scatter(1:length(obj.intra_authentication_processing), obj.intra_authentication_processing, 'filled');
            xlim([0, length(obj.intra_authentication_processing)]);  % Set x-axis limits
            title('Intra Authentication Processing');
            xlabel('Index');
            ylabel('Second');
            
            % Plot sum of intra_authentication_transmission and intra_authentication_processing
            figure;
            scatter(1:length(obj.intra_authentication_transmission), obj.intra_authentication_transmission + obj.intra_authentication_processing, 'filled');
            xlim([0, length(obj.intra_authentication_transmission)]);  % Set x-axis limits
            title('Total Intra Authentication');
            xlabel('Index');
            ylabel('Second');
            
            % Plot inter_authentication_transmission
            figure;
            scatter(1:length(obj.inter_authentication_transmission), obj.inter_authentication_transmission, 'filled');
            xlim([0, length(obj.inter_authentication_transmission)]);  % Set x-axis limits
            title('Inter Authentication Transmission');
            xlabel('Index');
            ylabel('Second');
            
            % Plot inter_authentication_processing
            figure;
            scatter(1:length(obj.inter_authentication_processing), obj.inter_authentication_processing, 'filled');
            xlim([0, length(obj.inter_authentication_processing)]);  % Set x-axis limits
            title('Inter Authentication Processing');
            xlabel('Index');
            ylabel('Second');
            
            % Plot sum of inter_authentication_transmission and inter_authentication_processing
            figure;
            scatter(1:length(obj.inter_authentication_transmission), obj.inter_authentication_transmission + obj.inter_authentication_processing, 'filled');
            xlim([0, length(obj.inter_authentication_transmission)]);  % Set x-axis limits
            title('Total Inter Authentication');
            xlabel('Index');
            ylabel('Second');
        end
    end
end
