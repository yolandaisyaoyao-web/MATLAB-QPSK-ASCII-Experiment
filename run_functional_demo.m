function summary = run_functional_demo(cfg)
%RUN_FUNCTIONAL_DEMO Verify ASCII recovery and generate report artifacts.

ensure_directory(cfg.metricsDir);
ensure_directory(cfg.figuresDir);

transmittedText = cfg.message;
bits = ascii_to_bits(transmittedText);
rng(cfg.functionalSeed, 'twister');
functionalLink = simulate_qpsk_link(bits, cfg.functionalEbNoDb, cfg);
recoveredText = bits_to_ascii(functionalLink.rxBits);
if ~strcmp(recoveredText, transmittedText)
    error('qpsk:FunctionalRecoveryFailed', ...
        'Recovered text does not equal the transmitted text.');
end

summary.transmittedText = transmittedText;
summary.recoveredText = recoveredText;
summary.bitErrors = functionalLink.bitErrors;
summary.ber = functionalLink.ber;

write_ascii_table(cfg, transmittedText);
write_functional_summary(cfg, summary);
write_parameter_summary(cfg);

constellationEbNoDb = cfg.ebnoDb([1, round((numel(cfg.ebnoDb)+1)/2), end]);
rng(cfg.functionalSeed + 100, 'twister');
constellationBits = rand(4000, 1) >= 0.5;
constellationLinks = cell(1, 3);
for k = 1:3
    rng(cfg.functionalSeed + 100 + k, 'twister');
    constellationLinks{k} = simulate_qpsk_link( ...
        constellationBits, constellationEbNoDb(k), cfg);
end

save(fullfile(cfg.metricsDir, 'functional_data.mat'), ...
    'summary', 'bits', 'functionalLink', 'constellationBits', ...
    'constellationEbNoDb', 'constellationLinks');

plot_transmit_constellation(cfg);
plot_receive_constellation(cfg, constellationLinks{1}, ...
    constellationEbNoDb(1), 'low', '低');
plot_receive_constellation(cfg, constellationLinks{2}, ...
    constellationEbNoDb(2), 'medium', '中');
plot_receive_constellation(cfg, constellationLinks{3}, ...
    constellationEbNoDb(3), 'high', '高');
plot_key_nodes(cfg, bits, functionalLink);
plot_spectrum(cfg, functionalLink.txWaveform);
end

function write_ascii_table(cfg, text)
decimalValues = double(text(:));
characters = string(num2cell(text(:)));
binaryValues = string(dec2bin(decimalValues, 8));
asciiTable = table(characters, decimalValues, binaryValues, ...
    'VariableNames', {'Character', 'Decimal', 'Binary'});
writetable(asciiTable, fullfile(cfg.metricsDir, 'ascii_demonstration.csv'));
end

function write_functional_summary(cfg, summary)
filePath = fullfile(cfg.metricsDir, 'functional_summary.txt');
fileId = open_text_file(filePath);
cleanup = onCleanup(@() fclose(fileId)); %#ok<NASGU>
fprintf(fileId, 'Transmitted text: %s\n', summary.transmittedText);
fprintf(fileId, 'Recovered text: %s\n', summary.recoveredText);
fprintf(fileId, 'Bit errors: %d\n', summary.bitErrors);
fprintf(fileId, 'BER: %.12g\n', summary.ber);
end

function write_parameter_summary(cfg)
filePath = fullfile(cfg.metricsDir, 'parameter_summary.txt');
fileId = open_text_file(filePath);
cleanup = onCleanup(@() fclose(fileId)); %#ok<NASGU>
fprintf(fileId, 'QPSK ASCII Communication Experiment Parameters\n');
fprintf(fileId, 'MATLAB release: %s\n', version('-release'));
fprintf(fileId, 'MATLAB version: %s\n', version);
fprintf(fileId, 'Default message: %s\n', cfg.message);
fprintf(fileId, 'ASCII bits per character: 8 (MSB first)\n');
fprintf(fileId, 'Modulation: Gray-coded QPSK\n');
fprintf(fileId, 'Bits per symbol: %d\n', cfg.bitsPerSymbol);
fprintf(fileId, 'Average symbol power: 1\n');
fprintf(fileId, 'RRC rolloff: %.2f\n', cfg.rolloff);
fprintf(fileId, 'RRC span (symbols): %d\n', cfg.filterSpanSymbols);
fprintf(fileId, 'Samples per symbol: %d\n', cfg.sps);
fprintf(fileId, 'Functional Eb/N0 (dB): %g\n', cfg.functionalEbNoDb);
fprintf(fileId, 'Functional RNG seed: %d\n', cfg.functionalSeed);
fprintf(fileId, 'BER RNG seed: %d\n', cfg.berSeed);
fprintf(fileId, 'Eb/N0 sweep (dB):%s\n', sprintf(' %g', cfg.ebnoDb));
fprintf(fileId, 'BER batch bits: %d\n', cfg.berBatchBits);
fprintf(fileId, 'BER maximum bits per point: %d\n', cfg.berMaxBits);
fprintf(fileId, 'BER target errors per point: %d\n', cfg.berTargetErrors);
fprintf(fileId, 'Synchronization assumption: ideal carrier and symbol timing\n');
end

function plot_transmit_constellation(cfg)
pairs = logical([0 0; 0 1; 1 1; 1 0]);
symbols = qpsk_modulate(reshape(pairs.', [], 1));
fig = report_figure();
scatter(real(symbols), imag(symbols), 120, 'filled');
grid on; axis equal; xlim([-1.2 1.2]); ylim([-1.2 1.2]);
xlabel('In-Phase'); ylabel('Quadrature');
title('发送端理想QPSK星座图');
save_figure(fig, fullfile(cfg.figuresDir, 'tx_constellation'));
end

function plot_receive_constellation(cfg, link, ebnoDb, suffix, levelText)
fig = report_figure();
scatter(real(link.rxSymbols), imag(link.rxSymbols), 10, '.');
grid on; axis equal; xlim([-2 2]); ylim([-2 2]);
xlabel('In-Phase'); ylabel('Quadrature');
title(sprintf('%s信噪比接收端QPSK星座图（Eb/N0 = %g dB）', ...
    levelText, ebnoDb));
save_figure(fig, fullfile(cfg.figuresDir, ...
    ['rx_constellation_' suffix]));
end

function plot_key_nodes(cfg, bits, link)
fig = report_figure();
tiledlayout(4, 1, 'TileSpacing', 'compact');

nexttile;
bitCount = min(48, numel(bits));
stairs(0:bitCount-1, double(bits(1:bitCount)), 'LineWidth', 1.1);
ylim([-0.2 1.2]); grid on; ylabel('Bit');
title('发送ASCII比特流');

nexttile;
symbolCount = min(24, numel(link.txSymbols));
stem(0:symbolCount-1, real(link.txSymbols(1:symbolCount)), ...
    'filled', 'DisplayName', 'I');
hold on;
stem(0:symbolCount-1, imag(link.txSymbols(1:symbolCount)), ...
    'DisplayName', 'Q');
grid on; ylabel('Amplitude'); legend('Location', 'eastoutside');
title('QPSK符号I/Q分量');

nexttile;
txCount = min(200, numel(link.txWaveform));
plot(0:txCount-1, real(link.txWaveform(1:txCount)), ...
    'DisplayName', 'I');
hold on;
plot(0:txCount-1, imag(link.txWaveform(1:txCount)), ...
    'DisplayName', 'Q');
grid on; ylabel('Amplitude'); legend('Location', 'eastoutside');
title('根升余弦发送滤波器输出波形');

nexttile;
matchedCount = min(240, numel(link.matchedWaveform));
plot(0:matchedCount-1, real(link.matchedWaveform(1:matchedCount)), ...
    'DisplayName', 'I');
hold on;
plot(0:matchedCount-1, imag(link.matchedWaveform(1:matchedCount)), ...
    'DisplayName', 'Q');
grid on; xlabel('Sample'); ylabel('Amplitude');
legend('Location', 'eastoutside');
title('匹配滤波器输出波形');

save_figure(fig, fullfile(cfg.figuresDir, 'key_node_waveforms'));
end

function plot_spectrum(cfg, waveform)
[powerDensity, frequency] = pwelch(waveform, [], [], 2048, 1, 'centered');
fig = report_figure();
plot(frequency, 10*log10(powerDensity + eps), 'LineWidth', 1.2);
grid on;
xlabel('Normalized Frequency (cycles/sample)');
ylabel('PSD (dB/sample)');
title('QPSK根升余弦成形信号频谱');
save_figure(fig, fullfile(cfg.figuresDir, 'signal_spectrum'));
end

function fig = report_figure()
fig = figure('Visible', 'off', 'Color', 'w', ...
    'Position', [100 100 1200 800]);
end

function fileId = open_text_file(filePath)
[fileId, message] = fopen(filePath, 'w');
if fileId < 0
    error('qpsk:OutputFileOpenFailed', '%s', message);
end
end

function ensure_directory(pathToCreate)
if ~isfolder(pathToCreate)
    [created, message] = mkdir(pathToCreate);
    if ~created
        error('qpsk:OutputDirectoryCreationFailed', '%s', message);
    end
end
end
