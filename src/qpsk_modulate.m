function symbols = qpsk_modulate(bits)
%QPSK_MODULATE Map bit pairs to unit-power Gray-coded QPSK symbols.
%   Mapping: 00, 01, 11, 10 proceed counterclockwise from quadrant I.

if ~(isnumeric(bits) || islogical(bits)) || ~iscolumn(bits) || ...
        any(~isfinite(double(bits))) || any((bits ~= 0) & (bits ~= 1))
    error('qpsk:NonBinaryInput', ...
        'Bits must be a finite binary column vector.');
end
if mod(numel(bits), 2) ~= 0
    error('qpsk:InvalidSymbolBitCount', ...
        'The number of bits must be divisible by two.');
end

pairs = reshape(double(bits), 2, []).';
symbols = ((1 - 2*pairs(:, 2)) + 1i*(1 - 2*pairs(:, 1))) / sqrt(2);
end
