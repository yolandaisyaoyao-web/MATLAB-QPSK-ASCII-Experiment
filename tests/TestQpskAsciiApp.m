classdef TestQpskAsciiApp < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addProjectPaths(testCase)
            projectRoot = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(projectRoot, 'src')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(projectRoot, 'app')));
        end
    end

    methods (Test)
        function interfaceUsesChinesePresentationText(testCase)
            app = QPSK_ASCII_App();
            cleanup = onCleanup(@() delete(app)); %#ok<NASGU>
            app.UIFigure.Visible = 'off';

            testCase.verifyEqual(app.UIFigure.Name, ...
                'QPSK ASCII通信演示系统');
            testCase.verifyEqual(app.RunSimulationButton.Text, '开始仿真');

            panels = findall(app.UIFigure, 'Type', 'uipanel');
            testCase.verifyTrue(any(strcmp({panels.Title}, ...
                '仿真控制与结果显示')));

            labels = findall(app.UIFigure, 'Type', 'uilabel');
            labelText = {labels.Text};
            expectedLabels = {'QPSK ASCII通信实验平台', ...
                '输入ASCII消息', '信噪比 Eb/N0（dB）', ...
                '恢复ASCII消息', '误码率 BER', '误码个数', '就绪'};
            for k = 1:numel(expectedLabels)
                testCase.verifyTrue(any(strcmp(labelText, expectedLabels{k})), ...
                    sprintf('缺少界面文本：%s', expectedLabels{k}));
            end

            testCase.verifyEqual(app.ConstellationAxes.XLabel.String, ...
                '同相分量');
            testCase.verifyEqual(app.ConstellationAxes.YLabel.String, ...
                '正交分量');
            testCase.verifyEqual(app.ConstellationAxes.Title.String, ...
                '接收QPSK星座图');
        end

        function noiselessRunUpdatesEveryRequiredOutput(testCase)
            app = QPSK_ASCII_App();
            cleanup = onCleanup(@() delete(app)); %#ok<NASGU>
            app.UIFigure.Visible = 'off';

            app.MessageEditField.Value = 'A';
            app.EbN0EditField.Value = Inf;
            app.runSimulation();

            testCase.verifyEqual( ...
                string(app.RecoveredMessageTextArea.Value), "A");
            testCase.verifyEqual(app.BERValueLabel.Text, '0');
            testCase.verifyEqual(app.BitErrorCountValueLabel.Text, '0');
            testCase.verifyNumElements(app.ConstellationAxes.Children, 1);
            testCase.verifyNumElements( ...
                app.ConstellationAxes.Children(1).XData, 4);
            testCase.verifyEqual(app.ConstellationAxes.Title.String, ...
                '接收QPSK星座图（Eb/N0 = Inf dB）');

            labels = findall(app.UIFigure, 'Type', 'uilabel');
            testCase.verifyTrue(any(strcmp({labels.Text}, '仿真完成')));
        end
    end
end
