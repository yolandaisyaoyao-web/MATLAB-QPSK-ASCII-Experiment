function result = run_ber_experiment(cfg)
%RUN_BER_EXPERIMENT Simulate and save Gray-QPSK BER performance in AWGN.

validate_config(cfg);
ensure_directory(cfg.metricsDir);
ensure_directory(cfg.figuresDir);

rng(cfg.berSeed, 'twister');
ebnoDb = cfg.ebnoDb(:).';
simulated = zeros(size(ebnoDb));
bitsTested = zeros(size(ebnoDb));
errors = zeros(size(ebnoDb));

for point = 1:numel(ebnoDb)
    while bitsTested(point) < cfg.berMaxBits && ...
            errors(point) < cfg.berTargetErrors
        batchSize = min(cfg.berBatchBits, ...
            cfg.berMaxBits - bitsTested(point));
        bits = rand(batchSize, 1) >= 0.5;
        link = simulate_qpsk_link(bits, ebnoDb(point), cfg);
        errors(point) = errors(point) + link.bitErrors;
        bitsTested(point) = bitsTested(point) + batchSize;
    end
    simulated(point) = errors(point)/bitsTested(point);
end

ebnoLinear = 10.^(ebnoDb/10);
theoretical = qfunc(sqrt(2*ebnoLinear));

result.ebnoDb = ebnoDb;
result.simulated = simulated;
result.theoretical = theoretical;
result.bitsTested = bitsTested;
result.errors = errors;

berTable = table(ebnoDb.', simulated.', theoretical.', ...
    bitsTested.', errors.', 'VariableNames', ...
    {'EbNo_dB', 'SimulatedBER', 'TheoreticalBER', ...
    'BitsTested', 'BitErrors'});
writetable(berTable, fullfile(cfg.metricsDir, 'ber_results.csv'));
save(fullfile(cfg.metricsDir, 'ber_results.mat'), 'result', 'berTable');

plotBer = simulated;
zeroError = errors == 0;
plotBer(zeroError) = 0.5 ./ bitsTested(zeroError);

fig = figure('Visible', 'off', 'Color', 'w');
cleanup = onCleanup(@() close(fig)); %#ok<NASGU>
semilogy(ebnoDb, plotBer, 'o-', 'LineWidth', 1.5, ...
    'MarkerSize', 6, 'DisplayName', 'Simulation');
hold on;
semilogy(ebnoDb, theoretical, '--', 'LineWidth', 1.5, ...
    'DisplayName', 'Theory');
if any(zeroError)
    semilogy(ebnoDb(zeroError), plotBer(zeroError), 'v', ...
        'LineWidth', 1.2, 'MarkerSize', 7, ...
        'DisplayName', 'Zero-error upper bound');
end
grid on;
xlabel('Eb/N0 (dB)');
ylabel('Bit Error Rate');
title('Gray编码QPSK在AWGN信道中的BER性能');
legend('Location', 'southwest');
savefig(fig, fullfile(cfg.figuresDir, 'ber_curve.fig'));
exportgraphics(fig, fullfile(cfg.figuresDir, 'ber_curve.png'), ...
    'Resolution', 300);
end

function validate_config(cfg)
required = {'ebnoDb', 'berSeed', 'berBatchBits', 'berMaxBits', ...
    'berTargetErrors', 'metricsDir', 'figuresDir'};
if ~isstruct(cfg) || ~all(isfield(cfg, required))
    error('qpsk:InvalidConfiguration', ...
        'BER configuration is missing one or more required fields.');
end
if isempty(cfg.ebnoDb) || ~isnumeric(cfg.ebnoDb) || ...
        ~isvector(cfg.ebnoDb) || any(~isfinite(cfg.ebnoDb))
    error('qpsk:InvalidConfiguration', ...
        'The Eb/N0 sweep must be a nonempty finite numeric vector.');
end
integerSettings = [cfg.berSeed, cfg.berBatchBits, ...
    cfg.berMaxBits, cfg.berTargetErrors];
if any(~isfinite(integerSettings)) || any(integerSettings <= 0) || ...
        any(integerSettings ~= fix(integerSettings)) || ...
        mod(cfg.berBatchBits, 2) ~= 0 || mod(cfg.berMaxBits, 2) ~= 0
    error('qpsk:InvalidConfiguration', ...
        'BER seeds, limits, and even bit counts must be positive integers.');
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
