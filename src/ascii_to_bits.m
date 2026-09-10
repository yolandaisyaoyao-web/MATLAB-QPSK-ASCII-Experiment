function bits = ascii_to_bits(text)
%ASCII_TO_BITS Convert a row of 7-bit ASCII characters to 8-bit MSB-first bits.

if ~ischar(text) || (~isrow(text) && ~isempty(text))
    error('qpsk:InvalidTextInput', ...
        'Input must be a character row vector.');
end
if any(double(text) > 127)
    error('qpsk:NonAsciiInput', ...
        'Input contains characters outside the 7-bit ASCII range.');
end

bitRows = dec2bin(double(text), 8) - '0';
bits = logical(reshape(bitRows.', [], 1));
end
