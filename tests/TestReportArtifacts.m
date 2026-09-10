classdef TestReportArtifacts < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPaths(testCase)
            projectRoot = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(projectRoot, 'src')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                projectRoot));
        end
    end

    methods (Test)
        function functionalDemoRecoversTextAndWritesData(testCase)
            c = report_config();
            cleanup = onCleanup(@() remove_temp_results(c.resultsDir)); %#ok<NASGU>

            summary = run_functional_demo(c);

            testCase.verifyEqual(summary.transmittedText, 'HELLO HEU');
            testCase.verifyEqual(summary.recoveredText, 'HELLO HEU');
            testCase.verifyEqual(summary.bitErrors, 0);
            testCase.verifyEqual(summary.ber, 0);

            asciiFile = fullfile(c.metricsDir, 'ascii_demonstration.csv');
            functionalFile = fullfile(c.metricsDir, 'functional_summary.txt');
            parameterFile = fullfile(c.metricsDir, 'parameter_summary.txt');
            dataFile = fullfile(c.metricsDir, 'functional_data.mat');
            testCase.verifyTrue(all(isfile( ...
                {asciiFile, functionalFile, parameterFile, dataFile})));

            importOptions = detectImportOptions(asciiFile, 'TextType', 'string');
            importOptions = setvartype(importOptions, 'Binary', 'string');
            asciiTable = readtable(asciiFile, importOptions);
            testCase.verifyEqual(asciiTable.Decimal.', ...
                double('HELLO HEU'));
            testCase.verifyEqual(asciiTable.Binary(1), "01001000");
            testCase.verifySubstring(fileread(functionalFile), ...
                'Recovered text: HELLO HEU');
            parameterText = fileread(parameterFile);
            testCase.verifySubstring(parameterText, 'RRC rolloff: 0.35');
            testCase.verifySubstring(parameterText, 'Samples per symbol: 8');
            testCase.verifySubstring(parameterText, 'Eb/N0 sweep (dB): 0 2 4 6 8 10 12');
        end

        function reportFiguresAreCompleteAndEditable(testCase)
            c = report_config();
            cleanup = onCleanup(@() remove_temp_results(c.resultsDir)); %#ok<NASGU>
            run_functional_demo(c);

            bases = {'tx_constellation', 'rx_constellation_low', ...
                'rx_constellation_medium', 'rx_constellation_high', ...
                'key_node_waveforms', 'signal_spectrum'};
            for k = 1:numel(bases)
                pngFile = fullfile(c.figuresDir, [bases{k} '.png']);
                figFile = fullfile(c.figuresDir, [bases{k} '.fig']);
                testCase.verifyTrue(isfile(pngFile), pngFile);
                testCase.verifyTrue(isfile(figFile), figFile);
                imageInfo = imfinfo(pngFile);
                testCase.verifyGreaterThanOrEqual(imageInfo.Width, 1800);
            end

            fig = openfig(fullfile(c.figuresDir, ...
                'tx_constellation.fig'), 'invisible');
            closeFigure = onCleanup(@() close(fig)); %#ok<NASGU>
            axesHandle = findall(fig, 'Type', 'axes');
            testCase.verifyEqual(string(axesHandle(1).Title.String), ...
                "发送端理想QPSK星座图");
        end
    end
end

function c = report_config()
c = qpsk_config();
c.resultsDir = tempname;
c.metricsDir = fullfile(c.resultsDir, 'metrics');
c.figuresDir = fullfile(c.resultsDir, 'figures');
end

function remove_temp_results(pathToRemove)
if isfolder(pathToRemove)
    rmdir(pathToRemove, 's');
end
end
