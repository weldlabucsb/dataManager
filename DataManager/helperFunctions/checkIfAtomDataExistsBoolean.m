function atomdata_exists = checkIfAtomDataExistsBoolean(dataDir)
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