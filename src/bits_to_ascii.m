function text = bits_to_ascii(bits)
%BITS_TO_ASCII Convert an 8-bit MSB-first bit column to a character row.

validate_bit_column(bits);
if mod(numel(bits), 8) ~= 0
    error('qpsk:InvalidBitCount', ...
        'The number of bits must be divisible by eight.');
end

bitRows = reshape(double(bits), 8, []).';
values = bitRows * (2.^(7:-1:0)).';
text = char(values.');
end

function validate_bit_column(bits)
if ~(isnumeric(bits) || islogical(bits)) || ~iscolumn(bits) || ...
        any(~isfinite(double(bits))) || any((bits ~= 0) & (bits ~= 1))
    error('qpsk:NonBinaryInput', ...
        'Bits must be a finite binary column vector.');
end
end
