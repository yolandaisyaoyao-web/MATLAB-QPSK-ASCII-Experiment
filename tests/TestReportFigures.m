classdef TestReportFigures < matlab.unittest.TestCase
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
        function createsStyledChinesePngsWithoutChangingOriginals(testCase)
            c = test_config();
            cleanup = onCleanup(@() remove_temp_results(c.resultsDir)); %#ok<NASGU>
            run_functional_demo(c);
            run_ber_experiment(c);

            originalFiles = dir(fullfile(c.figuresDir, '*'));
            originalFiles = originalFiles(~[originalFiles.isdir]);
            originalNames = {originalFiles.name};
            originalHashes = cellfun(@(name) file_hash( ...
                fullfile(c.figuresDir, name)), originalNames, ...
                'UniformOutput', false);

            [outputFiles, reportFontName] = generate_report_figures(c);
            testCase.verifyEqual(reportFontName, 'Microsoft YaHei UI');

            expectedNames = {
                '图1_QPSK发送星座图.png'
                '图2_QPSK系统BER性能曲线.png'
                '图3_低信噪比接收星座图.png'
                '图4_高信噪比接收星座图.png'
                '图5_关键节点波形图.png'
                '图6_QPSK信号频谱图.png'};
            testCase.verifyEqual(string(outputFiles(:)), string(fullfile( ...
                c.reportFiguresDir, expectedNames)));
            testCase.verifyTrue(all(isfile(outputFiles)));

            for k = 1:numel(outputFiles)
                imageInfo = imfinfo(outputFiles{k});
                testCase.verifyGreaterThanOrEqual(imageInfo.Width, 1800);
                testCase.verifyGreaterThanOrEqual(imageInfo.Height, 1100);
                testCase.verifyEqual(imageInfo.ResolutionUnit, 'meter');
                testCase.verifyEqual(imageInfo.XResolution, 11811, ...
                    'AbsTol', 1);
                testCase.verifyEqual(imageInfo.YResolution, 11811, ...
                    'AbsTol', 1);
            end

            finalHashes = cellfun(@(name) file_hash( ...
                fullfile(c.figuresDir, name)), originalNames, ...
                'UniformOutput', false);
            testCase.verifyEqual(finalHashes, originalHashes);
        end
    end
end

function c = test_config()
c = qpsk_config();
c.ebnoDb = [0 6 12];
c.berBatchBits = 20000;
c.berMaxBits = 40000;
c.berTargetErrors = 40;
c.resultsDir = tempname;
c.metricsDir = fullfile(c.resultsDir, 'metrics');
c.figuresDir = fullfile(c.resultsDir, 'figures');
c.reportFiguresDir = fullfile(c.resultsDir, 'report_figures');
end

function hash = file_hash(filePath)
engine = java.security.MessageDigest.getInstance('SHA-256');
engine.update(fileread_bytes(filePath));
hash = sprintf('%02x', typecast(engine.digest(), 'uint8'));
end

function bytes = fileread_bytes(filePath)
fileId = fopen(filePath, 'r');
if fileId < 0
    error('qpsk:TestFileOpenFailed', 'Cannot open %s.', filePath);
end
cleanup = onCleanup(@() fclose(fileId)); %#ok<NASGU>
bytes = fread(fileId, Inf, '*uint8');
end

function remove_temp_results(pathToRemove)
if isfolder(pathToRemove)
    rmdir(pathToRemove, 's');
end
end
