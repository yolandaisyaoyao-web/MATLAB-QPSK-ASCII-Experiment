function configure_simulink_file_generation()
%CONFIGURE_SIMULINK_FILE_GENERATION Keep generated caches outside the project.

generationRoot = fullfile(tempdir, 'qpsk_ascii_rf_simulink');
cacheFolder = fullfile(generationRoot, 'cache');
codeGenerationFolder = fullfile(generationRoot, 'codegen');
Simulink.fileGenControl('set', ...
    'CacheFolder', cacheFolder, ...
    'CodeGenFolder', codeGenerationFolder, ...
    'createDir', true);
end
