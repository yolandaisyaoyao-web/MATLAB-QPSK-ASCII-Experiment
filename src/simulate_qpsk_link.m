function out = simulate_qpsk_link(bits, ebnoDb, cfg)
%SIMULATE_QPSK_LINK Run a pulse-shaped QPSK link through complex AWGN.
%   The input and recovered bit streams are column vectors. An infinite
%   Eb/N0 selects the deterministic no-noise case.

if nargin < 3 || ~isstruct(cfg)
    error('qpsk:InvalidConfiguration', ...
        'The third input must be a QPSK experiment configuration structure.');
end
if ~(isnumeric(ebnoDb) && isreal(ebnoDb) && isscalar(ebnoDb) && ...
        (isfinite(ebnoDb) || (isinf(ebnoDb) && ebnoDb > 0)))
    error('qpsk:InvalidEbNo', ...
        'Eb/N0 must be a finite real scalar in dB or positive Inf.');
end

txSymbols = qpsk_modulate(bits);
bits = logical(bits);

rrc = rcosdesign(cfg.rolloff, cfg.filterSpanSymbols, cfg.sps, 'sqrt').';
upsampled = zeros(numel(txSymbols)*cfg.sps, 1);
upsampled(1:cfg.sps:end) = txSymbols;
txWaveform = conv(upsampled, rrc, 'full');

if isinf(ebnoDb)
    noise = zeros(size(txWaveform));
else
    ebnoLinear = 10^(ebnoDb/10);
    n0 = 1/(cfg.bitsPerSymbol*ebnoLinear);
    noise = sqrt(n0/2) .* ...
        (randn(size(txWaveform)) + 1i*randn(size(txWaveform)));
end
rxWaveform = txWaveform + noise;

matchedWaveform = conv(rxWaveform, rrc, 'full');
totalDelaySamples = numel(rrc) - 1;
lastSample = totalDelaySamples + 1 + ...
    (numel(txSymbols) - 1)*cfg.sps;
sampleIndices = (totalDelaySamples + 1:cfg.sps:lastSample).';
rxSymbols = matchedWaveform(sampleIndices);
rxBits = qpsk_demodulate(rxSymbols);

bitErrors = nnz(rxBits ~= bits);

out.bits = bits;
out.txSymbols = txSymbols;
out.txWaveform = txWaveform;
out.rxWaveform = rxWaveform;
out.matchedWaveform = matchedWaveform;
out.sampleIndices = sampleIndices;
out.rxSymbols = rxSymbols;
out.rxBits = rxBits;
out.bitErrors = bitErrors;
out.ber = bitErrors/numel(bits);
end
