classdef TestQpskLink < matlab.unittest.TestCase
    methods (TestClassSetup)
        function addSource(testCase)
            projectRoot = fileparts(fileparts(mfilename('fullpath')));
            sourceDir = fullfile(projectRoot, 'src');
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(sourceDir));
        end
    end

    methods (Test)
        function noiselessLinkRecoversEveryBitAfterDelayCompensation(testCase)
            c = qpsk_config();
            bits = logical(repmat([0; 0; 0; 1; 1; 1; 1; 0], 16, 1));

            out = simulate_qpsk_link(bits, Inf, c);

            testCase.verifyEqual(out.rxBits, bits);
            testCase.verifyEqual(out.bitErrors, 0);
            testCase.verifyEqual(out.ber, 0);
            testCase.verifyNumElements(out.rxSymbols, numel(bits)/2);
            testCase.verifyNumElements(out.txSymbols, numel(bits)/2);
            testCase.verifyEqual(out.sampleIndices(1), ...
                c.filterSpanSymbols*c.sps + 1);
        end

        function exposesEveryRequiredReferenceNode(testCase)
            c = qpsk_config();
            bits = ascii_to_bits(c.message);

            out = simulate_qpsk_link(bits, Inf, c);

            expectedFields = {'bits'; 'txSymbols'; 'txWaveform'; ...
                'rxWaveform'; 'matchedWaveform'; 'sampleIndices'; ...
                'rxSymbols'; 'rxBits'; 'bitErrors'; 'ber'};
            testCase.verifyEqual(sort(fieldnames(out)), sort(expectedFields));
            testCase.verifyGreaterThan(numel(out.txWaveform), numel(out.txSymbols));
            testCase.verifyGreaterThan(numel(out.matchedWaveform), ...
                numel(out.rxWaveform));
        end

        function highSnrAsciiRoundTripIsDeterministic(testCase)
            c = qpsk_config();
            bits = ascii_to_bits(c.message);

            rng(c.functionalSeed, 'twister');
            first = simulate_qpsk_link(bits, c.functionalEbNoDb, c);
            rng(c.functionalSeed, 'twister');
            second = simulate_qpsk_link(bits, c.functionalEbNoDb, c);

            testCase.verifyEqual(first.rxWaveform, second.rxWaveform);
            testCase.verifyEqual(bits_to_ascii(first.rxBits), c.message);
            testCase.verifyEqual(first.rxBits, bits);
        end

        function rejectsInvalidLinkInputs(testCase)
            c = qpsk_config();
            testCase.verifyError( ...
                @() simulate_qpsk_link([0; 1; 0], Inf, c), ...
                'qpsk:InvalidSymbolBitCount');
            testCase.verifyError( ...
                @() simulate_qpsk_link([0; 1], NaN, c), ...
                'qpsk:InvalidEbNo');
            testCase.verifyError( ...
                @() simulate_qpsk_link([0; 1], [0 2], c), ...
                'qpsk:InvalidEbNo');
        end
    end
end
