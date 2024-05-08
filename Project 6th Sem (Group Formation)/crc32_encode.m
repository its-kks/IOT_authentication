function [crc_data, data_bits] = crc32_encode(n)

    % Define the CRC-32 polynomial
    poly_bits = [1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1];

    % Convert the input decimal value to binary
    data_bits = dec2bin(n);

    % Pad the data with zeros at the end
    pad_len = length(poly_bits) - 1;
    data_bits = [data_bits, zeros(1, pad_len)];

    % Convert data_bits and poly_bits to logical arrays
    data_bits_logical = data_bits == '1';
    poly_bits_logical = poly_bits == 1;

    % Perform modulo-2 division
    for i = 1:length(data_bits_logical) - pad_len
        if data_bits_logical(i)
            data_bits_logical(i:i+pad_len) = xor(data_bits_logical(i:i+pad_len), poly_bits_logical);
        end
    end

    % Convert the logical array back to a binary string
    crc_bits = char(double(data_bits_logical(end-pad_len+1:end)) + '0');

    % Construct the final codeword
    crc_data = [data_bits(1:end-pad_len), crc_bits];

    
    % Simulate an error (flip a bit)
    if rand > 0.85
        crc_data_logical = crc_data == '1';
        crc_data_logical(10) = ~crc_data_logical(10);
        crc_data = char(double(crc_data_logical) + '0');
    end
end