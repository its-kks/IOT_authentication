function [demodulated_bit_str, snr] = modulate_demodulate(binary_string)
    % Convert binary string to binary values
    bits = double(binary_string == '1');

    % BPSK modulation
    modulated_signal = 2 * bits - 1;

    % Simulate AWGN channel
    snr_db = 10; % Set desired SNR in dB
    snr = 10^(snr_db / 10); % Convert to linear scale
    noise_variance = 1 / snr;
    noise = sqrt(noise_variance / 2) * randn(size(modulated_signal));
    received_signal = modulated_signal + noise;

    % Demodulation (BPSK)
    demodulated_bits = received_signal > 0;
    demodulated_bit_str = sprintf('%d', demodulated_bits);
    demodulated_bit_str = regexprep(demodulated_bit_str, ' ', ''); 


    % Estimate SNR
    signal_power = mean(modulated_signal.^2);
    noise_power = mean(noise.^2);
    snr_estimate = signal_power / noise_power;
    snr = 10 * log10(snr_estimate);
end