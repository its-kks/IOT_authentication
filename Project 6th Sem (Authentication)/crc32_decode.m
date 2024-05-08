function decoded_value = crc32_decode(crc_data)
    % Define the CRC-32 polynomial
    poly_bits = [1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1];

    % Convert crc_data to a logical array
    crc_data_logical = crc_data == '1';

    % Pad the received codeword with zeros at the end
    pad_len = length(poly_bits) - 1;
    crc_data_logical = [crc_data_logical, zeros(1, pad_len)];

    % Convert poly_bits to a logical array
    poly_bits_logical = poly_bits == 1;

    % Perform modulo-2 division
    for i = 1:length(crc_data_logical) - pad_len
        if crc_data_logical(i)
            crc_data_logical(i:i+pad_len) = xor(crc_data_logical(i:i+pad_len), poly_bits_logical);
        end
    end

    % Check the remainder
    remainder = crc_data_logical(end-pad_len+1:end);
    if all(~remainder)
        % No error, convert data back to decimal
        decoded_value = bin2dec(crc_data(1:end-pad_len));
    else
        % Error detected
        decoded_value = -1;
    end
end