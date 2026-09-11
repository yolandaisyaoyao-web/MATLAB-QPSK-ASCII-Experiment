function [outputFiles, reportFontName] = generate_report_figures(cfg)
%GENERATE_REPORT_FIGURES Create unified Chinese figures for the final report.
%   This function reads existing numeric results and writes only to
%   cfg.reportFiguresDir. It does not rerun or modify the communication link.

validate_inputs(cfg);
ensure_directory(cfg.reportFiguresDir);
reportFontName = select_report_font();

functional = load(fullfile(cfg.metricsDir, 'functional_data.mat'));
berData = load(fullfile(cfg.metricsDir, 'ber_results.mat'), 'result');

names = {
    '图1_QPSK发送星座图.png'
    '图2_QPSK系统BER性能曲线.png'
    '图3_低信噪比接收星座图.png'
    '图4_高信噪比接收星座图.png'
    '图5_关键节点波形图.png'
    '图6_QPSK信号频谱图.png'};
outputFiles = fullfile(cfg.reportFiguresDir, names);

plot_tx_constellation(outputFiles{1}, reportFontName);
plot_ber(berData.result, outputFiles{2}, reportFontName);
plot_rx_constellation(functional.constellationLinks{1}, ...
    functional.constellationEbNoDb(1), '低信噪比', outputFiles{3}, reportFontName);
plot_rx_constellation(functional.constellationLinks{end}, ...
    functional.constellationEbNoDb(end), '高信噪比', outputFiles{4}, reportFontName);
plot_key_nodes(functional.bits, functional.functionalLink, outputFiles{5}, reportFontName);
plot_spectrum(functional.functionalLink.txWaveform, outputFiles{6}, reportFontName);
end

function plot_tx_constellation(filePath, fontName)
pairs = logical([0 0; 0 1; 1 1; 1 0]);
symbols = qpsk_modulate(reshape(pairs.', [], 1));
fig = report_figure([7.2 7.1], fontName);
scatter(real(symbols), imag(symbols), 105, [0 0.4470 0.7410], ...
    'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.8);
grid on; axis equal; xlim([-1.2 1.2]); ylim([-1.2 1.2]);
xticks(-1:0.5:1); yticks(-1:0.5:1);
xlabel('同相分量 I'); ylabel('正交分量 Q');
title('QPSK发送星座图');
apply_report_style(fig, fontName);
export_report_png(fig, filePath);
end

function plot_rx_constellation(link, ebnoDb, levelText, filePath, fontName)
fig = report_figure([7.2 7.1], fontName);
scatter(real(link.rxSymbols), imag(link.rxSymbols), 11, ...
    [0 0.4470 0.7410], 'filled', 'MarkerFaceAlpha', 0.55);
grid on; axis equal; xlim([-2 2]); ylim([-2 2]);
xticks(-2:0.5:2); yticks(-2:0.5:2);
xlabel('同相分量 I'); ylabel('正交分量 Q');
title(sprintf('%s接收星座图（E_b/N_0 = %g dB）', ...
    levelText, ebnoDb), 'Interpreter', 'tex');
apply_report_style(fig, fontName);
export_report_png(fig, filePath);
end

function plot_ber(result, filePath, fontName)
plotBer = result.simulated;
zeroError = result.errors == 0;
plotBer(zeroError) = 0.5 ./ result.bitsTested(zeroError);

fig = report_figure([7 4.67], fontName);
semilogy(result.ebnoDb, plotBer, 'o-', 'Color', [0 0.4470 0.7410], ...
    'MarkerFaceColor', [0 0.4470 0.7410], 'DisplayName', '仿真结果');
hold on;
semilogy(result.ebnoDb, result.theoretical, '--', ...
    'Color', [0.8500 0.3250 0.0980], 'DisplayName', '理论值');
if any(zeroError)
    semilogy(result.ebnoDb(zeroError), plotBer(zeroError), 'v', ...
        'Color', [0.4660 0.6740 0.1880], ...
        'MarkerFaceColor', [0.4660 0.6740 0.1880], ...
        'DisplayName', '零误码上限');
end
grid on;
xlabel('E_b/N_0（dB）', 'Interpreter', 'tex');
ylabel('比特误码率（BER）');
title('QPSK系统BER性能曲线');
legend('Location', 'southwest');
apply_report_style(fig, fontName);
export_report_png(fig, filePath);
end

function plot_key_nodes(bits, link, filePath, fontName)
fig = report_figure([7 6.1], fontName);
layout = tiledlayout(4, 1, 'TileSpacing', 'compact', ...
    'Padding', 'compact');

nexttile;
bitCount = min(48, numel(bits));
stairs(0:bitCount-1, double(bits(1:bitCount)), ...
    'Color', [0 0.4470 0.7410]);
ylim([-0.2 1.2]); yticks([0 1]); grid on;
ylabel('比特值'); title('发送ASCII比特流');

nexttile;
symbolCount = min(24, numel(link.txSymbols));
stem(0:symbolCount-1, real(link.txSymbols(1:symbolCount)), ...
    'filled', 'Color', [0 0.4470 0.7410], 'DisplayName', 'I路');
hold on;
stem(0:symbolCount-1, imag(link.txSymbols(1:symbolCount)), ...
    'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'Q路');
grid on; ylabel('幅度'); title('QPSK符号I/Q分量');
legend('Location', 'eastoutside');

nexttile;
txCount = min(200, numel(link.txWaveform));
plot(0:txCount-1, real(link.txWaveform(1:txCount)), ...
    'Color', [0 0.4470 0.7410], 'DisplayName', 'I路');
hold on;
plot(0:txCount-1, imag(link.txWaveform(1:txCount)), ...
    'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'Q路');
grid on; ylabel('幅度'); title('根升余弦发送滤波器输出');
legend('Location', 'eastoutside');

nexttile;
matchedCount = min(240, numel(link.matchedWaveform));
plot(0:matchedCount-1, real(link.matchedWaveform(1:matchedCount)), ...
    'Color', [0 0.4470 0.7410], 'DisplayName', 'I路');
hold on;
plot(0:matchedCount-1, imag(link.matchedWaveform(1:matchedCount)), ...
    'Color', [0.8500 0.3250 0.0980], 'DisplayName', 'Q路');
grid on; xlabel('采样点'); ylabel('幅度'); title('匹配滤波器输出');
legend('Location', 'eastoutside');

title(layout, 'QPSK通信系统关键节点波形');
apply_report_style(fig, fontName);
export_report_png(fig, filePath);
end

function plot_spectrum(waveform, filePath, fontName)
[powerDensity, frequency] = pwelch(waveform, [], [], 2048, 1, 'centered');
fig = report_figure([7 4.67], fontName);
plot(frequency, 10*log10(powerDensity + eps), ...
    'Color', [0 0.4470 0.7410]);
grid on; xlim([-0.5 0.5]);
xlabel('归一化频率（周期/采样）');
ylabel('功率谱密度（dB/采样）');
title('QPSK根升余弦成形信号频谱');
apply_report_style(fig, fontName);
export_report_png(fig, filePath);
end

function fig = report_figure(sizeInches, fontName)
fig = figure('Visible', 'off', 'Color', 'w', ...
    'Units', 'inches', 'Position', [1 1 sizeInches], ...
    'InvertHardcopy', 'off');
set(fig, 'DefaultAxesFontName', fontName, ...
    'DefaultTextFontName', fontName, ...
    'DefaultAxesFontSize', 10.5, ...
    'DefaultLineLineWidth', 1.6, ...
    'DefaultStemLineWidth', 1.6);
end

function apply_report_style(fig, fontName)
axesHandles = findall(fig, 'Type', 'axes');
set(axesHandles, 'FontName', fontName, 'FontSize', 10.5, ...
    'LineWidth', 0.9, 'Box', 'on', 'Color', 'w', ...
    'GridAlpha', 0.18, 'MinorGridAlpha', 0.10);
for k = 1:numel(axesHandles)
    axesHandles(k).Title.FontName = fontName;
    axesHandles(k).Title.FontSize = 13;
    axesHandles(k).Title.FontWeight = 'bold';
    axesHandles(k).XLabel.FontName = fontName;
    axesHandles(k).XLabel.FontSize = 11.5;
    axesHandles(k).YLabel.FontName = fontName;
    axesHandles(k).YLabel.FontSize = 11.5;
end
legendHandles = findall(fig, 'Type', 'legend');
set(legendHandles, 'FontName', fontName, 'FontSize', 9.5, ...
    'Box', 'on');
textHandles = findall(fig, 'Type', 'text');
set(textHandles, 'FontName', fontName);
end

function fontName = select_report_font()
availableFonts = listfonts;
preferredFonts = {'Microsoft YaHei UI', 'Microsoft YaHei'};
for k = 1:numel(preferredFonts)
    if any(strcmpi(availableFonts, preferredFonts{k}))
        fontName = preferredFonts{k};
        return;
    end
end
fontName = get(groot, 'DefaultAxesFontName');
end

function export_report_png(fig, filePath)
cleanup = onCleanup(@() close(fig));
exportgraphics(fig, filePath, 'Resolution', 300, ...
    'BackgroundColor', 'white');
end

function validate_inputs(cfg)
requiredFields = {'metricsDir', 'reportFiguresDir'};
if ~isstruct(cfg) || ~all(isfield(cfg, requiredFields))
    error('qpsk:InvalidReportConfiguration', ...
        'Report configuration is missing required output paths.');
end
requiredFiles = {
    fullfile(cfg.metricsDir, 'functional_data.mat')
    fullfile(cfg.metricsDir, 'ber_results.mat')};
if ~all(isfile(requiredFiles))
    error('qpsk:MissingReportData', ...
        'Run the functional and BER experiments before generating report figures.');
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
