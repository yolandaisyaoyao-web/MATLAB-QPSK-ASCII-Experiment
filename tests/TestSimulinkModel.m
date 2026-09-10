classdef TestSimulinkModel < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPaths(testCase)
            projectRoot = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(projectRoot, 'src')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                projectRoot));
        end
    end

    methods (TestMethodTeardown)
        function closeModels(~)
            bdclose('all');
        end
    end

    methods (Test)
        function modelBuildsWithReadableRequiredChain(testCase)
            c = temporary_model_config();
            cleanup = onCleanup(@() remove_temp_model(c)); %#ok<NASGU>

            build_qpsk_model(c);

            testCase.verifyTrue(isfile(c.modelFile));
            load_system(c.modelFile);
            modelName = 'qpsk_ascii_system';
            requiredBlocks = {'ASCII_Bits_Input', 'QPSK_Modulator', ...
                'RRC_Tx_Filter', 'AWGN_Channel', 'RRC_Rx_Filter', ...
                'QPSK_Demodulator', 'Recovered_Bits', ...
                'ASCII_Output_Verification'};
            for k = 1:numel(requiredBlocks)
                testCase.verifyNotEmpty(find_system(modelName, ...
                    'SearchDepth', 1, 'Name', requiredBlocks{k}));
            end
        end

        function modelRunsAndRecoversConfiguredText(testCase)
            c = temporary_model_config();
            cleanup = onCleanup(@() remove_temp_model(c)); %#ok<NASGU>
            build_qpsk_model(c);

            summary = run_simulink_demo(c);

            testCase.verifyTrue(summary.recoveredExactly);
            testCase.verifyEqual(summary.transmittedText, c.message);
            testCase.verifyEqual(summary.recoveredText, c.message);
            testCase.verifyEqual(summary.bitErrors, 0);
            expectedNodes = {'txBits'; 'txSymbols'; 'txWaveform'; ...
                'rxWaveform'; 'matchedWaveform'; 'rxSymbols'; 'rxBits'};
            testCase.verifyEqual(sort(fieldnames(summary.loggedNodes)), ...
                sort(expectedNodes));
            testCase.verifyEqual(summary.loggedNodes.rxBits, ...
                summary.loggedNodes.txBits);
            testCase.verifyTrue(isfile(fullfile(c.metricsDir, ...
                'simulink_summary.txt')));
            summaryText = fileread(fullfile(c.metricsDir, ...
                'simulink_summary.txt'));
            testCase.verifySubstring(summaryText, ...
                'Model file: model/qpsk_ascii_system.slx');
            testCase.verifyFalse(contains(summaryText, fileparts(c.modelFile)));
            testCase.verifyTrue(isfile(fullfile(c.metricsDir, ...
                'simulink_data.mat')));
            projectRoot = fileparts(fileparts(mfilename('fullpath')));
            testCase.verifyEmpty(dir(fullfile(projectRoot, '**', '*.slxc')));
            testCase.verifyFalse(isfolder(fullfile(projectRoot, 'slprj')));
            testCase.verifyFalse(isfolder(fullfile(projectRoot, 'tests', 'slprj')));
        end
    end
end

function c = temporary_model_config()
c = qpsk_config();
c.functionalEbNoDb = Inf;
modelDir = tempname;
c.modelFile = fullfile(modelDir, 'qpsk_ascii_system.slx');
c.resultsDir = fullfile(modelDir, 'results');
c.metricsDir = fullfile(c.resultsDir, 'metrics');
c.figuresDir = fullfile(c.resultsDir, 'figures');
end

function remove_temp_model(c)
modelDir = fileparts(c.modelFile);
if isfolder(modelDir)
    rmdir(modelDir, 's');
end
end
