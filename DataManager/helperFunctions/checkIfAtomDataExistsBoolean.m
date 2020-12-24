function atomdata_exists = checkIfAtomDataExistsBoolean(dataDir)
% CHECKIFATOMDATAEXISTSBOOLEAN checks whether the provided path exists. If
% so, checks whether atomdata.mat exists in that folder. Returns False if
% folder or atomdata are not found, True if atomdata is found.

    %Check if the folder for the atom data exists
    if ~exist(dataDir,'dir')
        atomdata_exists = 0;
%         error(strcat("The directory (folder), ", dataDir, ", does not exist"))
    else
        if ~exist(strcat(dataDir, filesep, 'atomdata.mat'),'file')
            atomdata_exists = 0;
%             error(strcat("No atomdata.mat file exists in the directory ", dataDir))
        else
            atomdata_exists = 1;
        end
    end
end