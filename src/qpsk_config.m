function c = qpsk_config()
%QPSK_CONFIG Return centralized parameters for the QPSK ASCII experiment.

rootDir = fileparts(fileparts(mfilename('fullpath')));

c.message = 'HELLO HEU';
c.bitsPerSymbol = 2;
c.rolloff = 0.35;
c.sps = 8;
c.filterSpanSymbols = 10;
c.ebnoDb = 0:2:12;
c.functionalEbNoDb = 30;
c.functionalSeed = 1201;
c.berSeed = 2402;
c.berBatchBits = 200000;
c.berMaxBits = 2000000;
c.berTargetErrors = 200;
c.resultsDir = fullfile(rootDir, 'results');
c.modelFile = fullfile(rootDir, 'model', 'qpsk_ascii_system.slx');
end
