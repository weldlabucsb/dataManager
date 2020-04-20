classdef RunData
    %An object that holds a RunInfo (or RunInfoSubset) object and the
    %associated atomdata file.  
    %
    %NOTE that for RunInfoSubset's, the atom data
    %will only contain the subset of the data taken in that run that
    %satisfy the conditions given in the RunInfoSubsets
    %
    %   Generated from a RunInfo (or RunInfoSubset) object.  Note the RunInfo
    %   object must have a working filepath to a folder that contains an
    %   "atomdata" object.  This filepath is automatically generated from a
    %   given Citadel Directory folder at the creation of RunInfo objects,
    %   but you may specify an alternative directory where the atom data is
    %   stored.
    
    properties
        Info
        Atomdata
    end
    
    methods
        function obj = RunData(runInfo,specifiedFolderPath)
            %RunInfo as an object of the RunInfo class object.  This
            %usually contains the file path to the atomdata as specified on
            %the citadel, but you may specify a different folder path if
            %necessary (e.g. atom data is stored locally)
            
            if nargin>1  
                checkIfAtomDataExists(specifiedFolderPath)
                folderPath = specifiedFolderPath;
            else
                checkIfAtomDataExists(runInfo.FilePath)
                folderPath = runInfo.FilePath;
            end
            
            obj.Info = runInfo;
            
            %Load fullatom data before removing some
            fullAtomdata = load([folderPath filesep 'atomdata.mat']).atomdata;
            
            error('Under Construction')  % NEED TO HAVE A GOOD WAY TO CHECK which atom data elements are in the subinfo  PROBABLY want to name properties same as cicero
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

function checkIfAtomDataExists(dataDir)
    %Check if the folder for the atom data exists
    if ~exist(dataDir,'dir')
        error(['The directory (folder).' dataDir ' does not exist'])
    end
    if ~exist([dataDir filesep 'atomdata.mat'],'file')
        error(['No atomdata.mat file exists in the directory ',dataDir])
    end
end