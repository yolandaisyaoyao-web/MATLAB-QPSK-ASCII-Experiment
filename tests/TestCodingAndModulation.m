classdef TestCodingAndModulation < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addSource(testCase)
            projectRoot = fileparts(fileparts(mfilename('fullpath')));
            sourceDir = fullfile(projectRoot, 'src');
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(sourceDir));
        end
    end

    methods (Test)
        function configMatchesRequirements(testCase)
            c = qpsk_config();
            testCase.verifyEqual(c.message, 'HELLO HEU');
            testCase.verifyEqual(c.rolloff, 0.35);
            testCase.verifyEqual(c.sps, 8);
            testCase.verifyEqual(c.ebnoDb, 0:2:12);
        end

        function asciiUsesEightBitMsbFirst(testCase)
            testCase.verifyEqual(ascii_to_bits('A'), ...
                logical([0; 1; 0; 0; 0; 0; 0; 1]));
            testCase.verifyEqual(bits_to_ascii(ascii_to_bits('HELLO HEU')), ...
                'HELLO HEU');
        end

        function rejectsInvalidAsciiInputs(testCase)
            testCase.verifyError(@() ascii_to_bits(char(200)), ...
                'qpsk:NonAsciiInput');
            testCase.verifyError(@() ascii_to_bits(65), ...
                'qpsk:InvalidTextInput');
            testCase.verifyError(@() ascii_to_bits(['A'; 'B']), ...
                'qpsk:InvalidTextInput');
        end

        function rejectsInvalidBitInputs(testCase)
            testCase.verifyError(@() bits_to_ascii([0; 1; 0]), ...
                'qpsk:InvalidBitCount');
            testCase.verifyError(@() bits_to_ascii([0; 2; zeros(6, 1)]), ...
                'qpsk:NonBinaryInput');
            testCase.verifyError(@() qpsk_modulate([0; 2]), ...
                'qpsk:NonBinaryInput');
            testCase.verifyError(@() qpsk_modulate([0; 1; 0]), ...
                'qpsk:InvalidSymbolBitCount');
        end

        function grayMapAndInverseAreExact(testCase)
            pairs = logical([0 0; 0 1; 1 1; 1 0]);
            expected = [1+1i; -1+1i; -1-1i; 1-1i] / sqrt(2);
            bits = reshape(pairs.', [], 1);

            testCase.verifyEqual(qpsk_modulate(bits), expected, ...
                'AbsTol', 10*eps);
            testCase.verifyEqual(qpsk_demodulate(expected), bits);
        end

        function demodulatorRejectsInvalidShape(testCase)
            testCase.verifyError(@() qpsk_demodulate([1+1i, -1-1i]), ...
                'qpsk:InvalidSymbolInput');
        end
    end
end
