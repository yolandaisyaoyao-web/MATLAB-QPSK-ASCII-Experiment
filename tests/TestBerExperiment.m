classdef TestBerExperiment < matlab.unittest.TestCase
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
        function configDefinesSeparatedResultDirectories(testCase)
            c = qpsk_config();
            testCase.verifyEqual(c.metricsDir, ...
                fullfile(c.resultsDir, 'metrics'));
            testCase.verifyEqual(c.figuresDir, ...
                fullfile(c.resultsDir, 'figures'));
        end

        function reducedSweepMatchesTheoryAndSavesArtifacts(testCase)
            c = reduced_config();
            cleanup = onCleanup(@() remove_temp_results(c.resultsDir)); %#ok<NASGU>

            result = run_ber_experiment(c);

            testCase.verifyEqual(result.ebnoDb, [0 6]);
            testCase.verifyEqual(result.theoretical, ...
                [0.0786496035251426 0.00238829078093281], ...
                'AbsTol', 1e-14);
            testCase.verifySize(result.simulated, [1 2]);
            testCase.verifyGreaterThan(result.simulated(1), result.simulated(2));
            testCase.verifyGreaterThanOrEqual(result.bitsTested, [20000 20000]);
            testCase.verifyEqual(mod(result.bitsTested, 2), [0 0]);

            standardError = sqrt(result.theoretical .* ...
                (1-result.theoretical) ./ result.bitsTested);
            tolerance = max(5*standardError, 0.4*result.theoretical);
            testCase.verifyLessThanOrEqual( ...
                abs(result.simulated-result.theoretical), tolerance);

            expected = {
                fullfile(c.metricsDir, 'ber_results.csv')
                fullfile(c.metricsDir, 'ber_results.mat')
                fullfile(c.figuresDir, 'ber_curve.png')
                fullfile(c.figuresDir, 'ber_curve.fig')};
            testCase.verifyTrue(all(cellfun(@isfile, expected)));

            savedTable = readtable(expected{1});
            testCase.verifyEqual(savedTable.Properties.VariableNames, ...
                {'EbNo_dB','SimulatedBER','TheoreticalBER', ...
                'BitsTested','BitErrors'});
        end

        function sweepIsReproducibleFromConfiguredSeed(testCase)
            firstConfig = reduced_config();
            secondConfig = reduced_config();
            secondConfig.resultsDir = [secondConfig.resultsDir '_repeat'];
            secondConfig.metricsDir = fullfile(secondConfig.resultsDir, 'metrics');
            secondConfig.figuresDir = fullfile(secondConfig.resultsDir, 'figures');
            cleanupFirst = onCleanup( ...
                @() remove_temp_results(firstConfig.resultsDir)); %#ok<NASGU>
            cleanupSecond = onCleanup( ...
                @() remove_temp_results(secondConfig.resultsDir)); %#ok<NASGU>

            first = run_ber_experiment(firstConfig);
            second = run_ber_experiment(secondConfig);

            testCase.verifyEqual(second.simulated, first.simulated);
            testCase.verifyEqual(second.bitsTested, first.bitsTested);
            testCase.verifyEqual(second.errors, first.errors);
        end
    end
end

function c = reduced_config()
c = qpsk_config();
c.ebnoDb = [0 6];
c.berBatchBits = 20000;
c.berMaxBits = 40000;
c.berTargetErrors = 40;
c.resultsDir = tempname;
c.metricsDir = fullfile(c.resultsDir, 'metrics');
c.figuresDir = fullfile(c.resultsDir, 'figures');
end

function remove_temp_results(pathToRemove)
if isfolder(pathToRemove)
    rmdir(pathToRemove, 's');
end
end
