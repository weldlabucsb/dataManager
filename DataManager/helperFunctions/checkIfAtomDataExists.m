function checkIfAtomDataExists(dataDir)
    %Check if the folder for the atom data exists
    if ~exist(dataDir,'dir')
        error(strcat('The directory (folder).', dataDir ', does not exist'))
    end
    if ~exist(strcat(dataDir, filesep, 'atomdata.mat'),'file')
        error(strcat('No atomdata.mat file exists in the directory ', dataDir))
    end
end