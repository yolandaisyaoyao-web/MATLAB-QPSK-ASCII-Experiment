function bits = qpsk_demodulate(symbols)
%QPSK_DEMODULATE Make hard Gray-coded QPSK decisions by quadrant.

if ~isnumeric(symbols) || ~iscolumn(symbols) || ...
        any(~isfinite(real(symbols))) || any(~isfinite(imag(symbols)))
    error('qpsk:InvalidSymbolInput', ...
        'Symbols must be a finite numeric column vector.');
end

pairs = [imag(symbols) < 0, real(symbols) < 0];
bits = reshape(pairs.', [], 1);
end
