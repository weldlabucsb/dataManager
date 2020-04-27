function checkIfAtomDataExists(dataDir)
    %Check if the folder for the atom data exists
    if ~exist(dataDir,'dir')
        error(['The directory (folder).' dataDir ' does not exist'])
    end
    if ~exist([dataDir filesep 'atomdata.mat'],'file')
        error(['No atomdata.mat file exists in the directory ',dataDir])
    end
end