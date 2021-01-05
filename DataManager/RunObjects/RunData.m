classdef RunData<RunInfoSubset
    %An object that holds a RunInfo (or RunInfoSubset) information and the
    %associated atomdata file.  It is a subclass of RunInfoSubset, so all
    %properties of RunInfo and RunInfoSubset are inherited by this class.
    %
    %NOTE that for RunInfoSubset's, the atom data
    %will only contain the subset of the data taken in that run that
    %satisfy the conditions given in the RunInfoSubsets
    %
    %   Can be generated from a RunInfo (or RunInfoSubset) object by using 
    %   the .  Note the constructRunInfo method function.
    %   object must have a working filepath to a folder that contains an
    %   "atomdata" object.  This filepath is automatically generated from a
    %   given Citadel Directory folder at the creation of RunInfo objects,
    %   but you may specify an alternative directory where the atom data is
    %   stored.
    
    properties
        Atomdata
    end
    
    methods
        function obj = RunData()
            %Should be constructed as empty.  Then either (1) use the
            %constructRunInfo method function or (2) constructTable
        end
        
        
        
        function obj = constructRunInfo(obj,runInfo,specifiedFolderPath,atomdata)
            %RunInfo as an object of the RunInfo (or RunInfoSubset) class 
            %object.  This usually contains the file path to the atomdata 
            %as specified on the citadel, but you may specify a different 
            %folder path in a char array as specifiedFolderPath if necessary 
            %(e.g. atom data is stored locally)
            
            if (nargin<3)||(isempty(specifiedFolderPath))
                checkIfAtomDataExists(runInfo.FilePath)
                folderPath = runInfo.FilePath;
            else
                checkIfAtomDataExists(specifiedFolderPath)
                folderPath = specifiedFolderPath;
            end
            
            if nargin<2
                % For the case that the runInfo in the RunData object has
                % already been set up, but the atomdata needs to be loaded.
                runInfo=obj;
            end
            
            for cellProp=transpose(properties(runInfo))
                prop=cellProp{1};
                obj.(prop) = runInfo.(prop);
            end
            
            if (nargin<4)
                %Load full atom data before removing some, assuming
                %atomdata is not provided
                disp(['    Loading atomdata from ' num2str(runInfo.Month) '/' num2str(runInfo.Day) '/' num2str(runInfo.Year) ' Run: ' runInfo.RunFolder])
                atomdata = load([folderPath filesep 'atomdata.mat']).atomdata;
            end
                
            
            for cellVar=transpose(fieldnames(runInfo.vars))
                % Trim the atomdata on each loop to only those that satisfy
                % the parameters given in the runInfo (which might be a run sub info)
                var = cellVar{1};       
                
                % A function for handling special variable considerations
                [satisAD,isSC] = specialConditions(var,runInfo,atomdata);
                
                
                if ~isSC
                    cicVar = translateVarName(var);
                    
                    desiredVals = runInfo.vars.(var);
        
                    adVars = [atomdata.vars];
                    % Changed on 2021/01/05 to ignore cases where cicVar
                    % not present in subset of RunDatas. To revert: remove
                    % if/else statment, replace warning with
                    % assert(isfield(advars,cicVar),'error message').
                    if ~isfield(adVars,cicVar)
                        warning(['The variable ' cicVar ' is not a variable stored in atomdata.  Maybe you want to specify it as a noncicero variable in ncVars? Otherwise, you can use translateVarName.m']);
                    else
                        atomdataVals = [adVars.(cicVar)];

                        tol = 10^(-3);
                        satisAD = false(size(atomdataVals));
                        for ii=1:length(desiredVals)
                            if desiredVals(ii)<10^(-8)
                                if mean(atomdataVals)<10^(-8)
                                    satisThisVal = true(size(atomdataVals));
                                else
                                    satisThisVal = abs(atomdataVals-desiredVals(ii))./mean(atomdataVals)<tol;
                                end
                            else
                                satisThisVal = abs(atomdataVals-desiredVals(ii))./desiredVals(ii)<tol;
                            end
                            satisAD = satisAD|satisThisVal;
                        end
                    end
                end
                if all(~satisAD)
                    warning(['No atomdata was found to fit the variable values given in the run info for ', runInfo.RunID,' KILLED BY VARIABLE ',var])
                    obj.Atomdata=atomdata(satisAD);
                    
                    
%                     disp([obj.RunID ' BY VAR ' var])
%                     disp('atomdataVals')
%                     disp(atomdataVals)
                    return
                end
                
                %Shortening atomdata to only the ones that satisfy the
                %conditions
                atomdata = atomdata(satisAD);
                
                
                
                if any(~satisAD)
                    % Update GeneratingConditions in case it turns out that
                    % the stated runInfo.GeneratingConditions does not
                    % accurately reflect what parts of atomdata were
                    % ignored.

                    obj.GeneratingConditions = horzcat(...
                        obj.GeneratingConditions,...
                        {var},...
                        convertNumArray2CellString(runInfo.vars.(var),','));
                    obj = obj.appendSubset;
                end
                
                
            end 
            
            obj.Atomdata = atomdata;
        end %Iterating over fields
        
        
        
        function obj = constructTable(obj,CSVTableLine,dataDir,ncVars,specifiedFolderPath)
            %Constructs the object from a CSV Table line (given as a
            %matlab table object) in the same format as RunInfo is
            %constructed.  
            %
            %   specifiedFolderPath is an optional input in case the
            %   automatically generated folder path to the citadel is not
            %   the one you want (e.g. if you stored the atomdata locally on 
            %   your computer somewhere)
            if nargin<4
                ncVars = {};
            end
            obj = obj.writeRunInfo(CSVTableLine,dataDir,ncVars);
            
            if nargin<5
                specifiedFolderPath = obj.FilePath;
            end
            
            runInfo=obj;
            obj = obj.constructRunInfo(runInfo,specifiedFolderPath);
        end
        
        
        function [dataMatrices,tiffFiles,ROI]=getRawTiffData(obj,type,useROI,customROI)
            % type should be either "dark", "light", or "atoms"
            % atoms is the image of the atomic cloud on the camera (atoms present, resonant light hitting them)
            % dark is the image taken with no atoms and no resonant light
            % light is the image of just the resonant light hitting the
            % camera, with no atoms in the chamber.
            % See Cora's thesis for more details.
            %
            % Outputs are a matrix of the pixel values in the tif file.
            % tiffFile is the filepath (on this machine) to the tiff file
            % ROI is the ROI saved for the corresponding atom data.
            %
            % useROI is a logical variable.  When true, the dataMatrix is
            % limited to the ROI as saved in atom data.  When false, it
            % returns the dataMatrix for the whole file.
            %
            % The customROI is an ROI set by the user in the case that the
            % ROI determined by doitAndor is not what is desired (an issue
            % when there are rotations).  Format is [lowY,highY,lowX,highX]
            
            if nargin<3
                useROI=false;
            end

            
            if isempty(obj.Atomdata)
                error('No atomdata in the RunData object that you tried to get the tiff file data for.')
            end
            atomdata = obj.Atomdata;
            type = lower(type);
            
            if ~isfield(atomdata(1),type)
                error(['The atom data you tried to get the tif file for does not contain a file path for the ' type ' image.'])
            end
            if isempty(atomdata(1).(type))
                error(['The atom data you tried to get the tif file for does not contain a file path for the ' type ' image.'])
            end
            
            if useROI
                ROI = atomdata.ROI;
            else
                ROI = [];
            end
            if nargin>=4
                ROI = customROI;
                useROI = true;
            end
            
            % Initializing empty
            dataMatrices = cell(size(atomdata));
            tiffFiles = cell(size(atomdata));
            
            for ii = 1:length(atomdata)
                % Getting tiff files
                if length(split(atomdata(ii).(type),'\'))>1
                    fileSeparatedName = transpose(split(atomdata(ii).(type),'\'));
                elseif length(split(atomdata(ii).(type),'/'))>1
                    fileSeparatedName = transpose(split(atomdata(ii).(type),'/'));
                else
                    error(['Was not able to separate the ' type ' tiff file by file separators for run ' obj.RunID])
                end
                
                % Building up the tiff file path for this machine
                thisTiffFile = obj.FilePath;
                thisTiffFile = horzcat(thisTiffFile, filesep, fileSeparatedName{end});
                tiffFiles{ii} = thisTiffFile;
                
                if useROI
                    % Constructing the matrix of data points.
                    thisDataMatrix = double(imread(thisTiffFile, 'PixelRegion',{[ROI(1),ROI(2)],[ROI(3),ROI(4)]}));
                    if ii<10
                        disp(['      Loading ' type ' tiff file  ' num2str(ii) '/' num2str(length(atomdata)) ' for atomdata in run ' obj.RunID])
                    else
                        disp(['      Loading ' type ' tiff file ' num2str(ii) '/' num2str(length(atomdata)) ' for atomdata in run ' obj.RunID])
                    end
                else
                    thisDataMatrix = double(imread(thisTiffFile));
                    if ii<10
                        disp(['      Loading ' type ' tiff file  ' num2str(ii) '/' num2str(length(atomdata)) ' for atomdata in run ' obj.RunID])
                    else
                        disp(['      Loading ' type ' tiff file ' num2str(ii) '/' num2str(length(atomdata)) ' for atomdata in run ' obj.RunID])
                    end
                end
                dataMatrices{ii} = thisDataMatrix;
            end

        end
        
    end%methods
end%class