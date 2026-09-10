function summary = run_simulink_demo(cfg)
%RUN_SIMULINK_DEMO Execute the saved model and verify recovered ASCII text.

if ~isfile(cfg.modelFile)
    build_qpsk_model(cfg);
end
ensure_directory(cfg.metricsDir);
configure_simulink_file_generation();

[~, modelName] = fileparts(cfg.modelFile);
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
load_system(cfg.modelFile);
cleanup = onCleanup(@() close_if_loaded(modelName)); %#ok<NASGU>
assign_model_variables(modelName, cfg);

simulation = sim(modelName, 'StopTime', '0', ...
    'ReturnWorkspaceOutputs', 'on');
transmittedBits = ascii_to_bits(cfg.message);
bitCount = numel(transmittedBits);
symbolCount = bitCount/cfg.bitsPerSymbol;

rawTxBits = column_data(simulation.get('txBitsLog'));
rawTxSymbols = column_data(simulation.get('txSymLog'));
rxBits = logical(column_data(simulation.get('rxBitsLog')));

loggedNodes.txBits = logical(rawTxBits(1:bitCount));
loggedNodes.txSymbols = rawTxSymbols(1:symbolCount);
loggedNodes.txWaveform = column_data( ...
    simulation.get('txWaveLog'));
loggedNodes.rxWaveform = column_data( ...
    simulation.get('rxWaveLog'));
loggedNodes.matchedWaveform = column_data( ...
    simulation.get('matchedLog'));
loggedNodes.rxSymbols = column_data( ...
    simulation.get('rxSymLog'));
loggedNodes.rxBits = rxBits(1:bitCount);

recoveredText = bits_to_ascii(loggedNodes.rxBits);
bitErrors = nnz(loggedNodes.rxBits ~= loggedNodes.txBits);
recoveredExactly = bitErrors == 0 && strcmp(recoveredText, cfg.message);
if ~recoveredExactly
    error('qpsk:SimulinkRecoveryFailed', ...
        'Simulink recovered %d erroneous bits.', bitErrors);
end

summary.transmittedText = cfg.message;
summary.recoveredText = recoveredText;
summary.bitErrors = bitErrors;
summary.recoveredExactly = recoveredExactly;
summary.loggedNodes = loggedNodes;

save(fullfile(cfg.metricsDir, 'simulink_data.mat'), 'summary');
write_summary(cfg, summary);
end

function assign_model_variables(modelName, cfg)
bits = double(ascii_to_bits(cfg.message));
tailBits = zeros(2*cfg.filterSpanSymbols, 1);
symbolCount = numel(bits)/cfg.bitsPerSymbol;
modelWorkspace = get_param(modelName, 'ModelWorkspace');
assignin(modelWorkspace, 'txBitsIn', [bits; tailBits]);
assignin(modelWorkspace, 'simulinkRolloff', cfg.rolloff);
assignin(modelWorkspace, 'simulinkFilterSpan', cfg.filterSpanSymbols);
assignin(modelWorkspace, 'simulinkSps', cfg.sps);
assignin(modelWorkspace, 'simulinkNoiseSeed', cfg.functionalSeed);
assignin(modelWorkspace, 'simulinkSNRdB', cfg.functionalEbNoDb + ...
    10*log10(cfg.bitsPerSymbol) - 10*log10(cfg.sps));
assignin(modelWorkspace, 'simulinkWaveformLength', ...
    (symbolCount + cfg.filterSpanSymbols)*cfg.sps);
firstSample = cfg.filterSpanSymbols*cfg.sps + 1;
assignin(modelWorkspace, 'simulinkSampleIndices', ...
    firstSample:cfg.sps:firstSample+(symbolCount-1)*cfg.sps);
end

function data = column_data(value)
if isa(value, 'timeseries')
    value = value.Data;
end
data = value(:);
end

function write_summary(cfg, summary)
filePath = fullfile(cfg.metricsDir, 'simulink_summary.txt');
[fileId, message] = fopen(filePath, 'w');
if fileId < 0
    error('qpsk:OutputFileOpenFailed', '%s', message);
end
cleanup = onCleanup(@() fclose(fileId)); %#ok<NASGU>
fprintf(fileId, 'Model file: model/qpsk_ascii_system.slx\n');
fprintf(fileId, 'Transmitted text: %s\n', summary.transmittedText);
fprintf(fileId, 'Recovered text: %s\n', summary.recoveredText);
fprintf(fileId, 'Bit errors: %d\n', summary.bitErrors);
fprintf(fileId, 'Recovered exactly: %d\n', summary.recoveredExactly);
fprintf(fileId, 'Logged nodes: txBits, txSymbols, txWaveform, rxWaveform, matchedWaveform, rxSymbols, rxBits\n');
end

function ensure_directory(pathToCreate)
if ~isfolder(pathToCreate)
    [created, message] = mkdir(pathToCreate);
    if ~created
        error('qpsk:OutputDirectoryCreationFailed', '%s', message);
    end
end
end

function close_if_loaded(modelName)
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
end
