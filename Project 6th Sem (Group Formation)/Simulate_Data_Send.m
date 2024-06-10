function [received_message,no_of_packets] = Simulate_Data_Send(message,packet_size)
%This function simulate sending of data by simulating encoding, decoding,
%modulation, demodulation and packet generation

% packet_size is in bytes
    python_code = [
        "import zlib"
        "import numpy as np"
        ""
        "def divide_into_packets(data, packet_size):"
        "    packets = []"
        "    for i in range(0, len(data), packet_size):"
        "        packet = data[i:i+packet_size]"
        "        packets.append(packet)"
        "    return packets"
        ""
        "def crc32_encode(packet):"
        "    crc = zlib.crc32(packet.encode())"
        "    return crc.to_bytes(4, byteorder='little') + packet.encode()"
        ""
        "def crc32_decode(encoded_packet):"
        "    crc = int.from_bytes(encoded_packet[:4], byteorder='little')"
        "    packet = encoded_packet[4:]"
        "    check = zlib.crc32(packet)"
        "    if check == crc:"
        "        return packet.decode()"
        "    else:"
        "        return None"
        ""
        "def bpsk_modulate(packet):"
        "    bits = bin(int.from_bytes(packet, byteorder='big'))[2:].zfill(len(packet)*8)"
        "    return np.array([1 if bit == '1' else -1 for bit in bits])"
        ""
        "def bpsk_demodulate(modulated_packet):"
        "    return int(''.join(['1' if bit >= 0 else '0' for bit in modulated_packet]), 2).to_bytes((len(modulated_packet)+7)//8, byteorder='big')"
        ""
        "def simulate_sending_data(data, packet_size):"
        "    packets = divide_into_packets(data, packet_size)"
        "    encoded_packets = [crc32_encode(packet) for packet in packets]"
        "    modulated_packets = [bpsk_modulate(encoded_packet) for encoded_packet in encoded_packets]"
        "    demodulated_packets = [bpsk_demodulate(modulated_packet) for modulated_packet in modulated_packets]"
        "    decoded_packets = [crc32_decode(demodulated_packet) for demodulated_packet in demodulated_packets]"
        "    decoded_packets = [packet for packet in decoded_packets if packet is not None]"
        "    return [''.join(decoded_packets),len(packets)]"
    ];

    pyrun(python_code);
    packet_size = string(packet_size);

    result = pyrun(strcat("ans = simulate_sending_data('" , message , "'," , packet_size,")"),"ans");
    received_message = string(result(1));
    no_of_packets = string(result(2));

end

