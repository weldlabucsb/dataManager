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
                    assert(isfield(adVars,cicVar),['The variable ' cicVar ' is not a variable stored in atomdata.  Maybe you want to specify it as a noncicero variable in ncVars? Otherwise, you can use translateVarName.m'])
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
                if all(~satisAD)
                    warning(['No atomdata was found to fit the variable values given in the run info for ', runInfo.RunID,' KILLED BY VARIABLE ',var])
                    obj.Atomdata=atomdata(satisAD);
                    
                    
%                     disp([obj.RunID ' BY VAR ' var])
%                     disp('atomdataVals')
%                     disp(atomdataVals)
                    return
                end
                
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
        
        
        
        function obj = constructTable(obj,CSVTableLine,citadelDir,ncVars,specifiedFolderPath)
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
            obj = obj.writeRunInfo(CSVTableLine,citadelDir,ncVars);
            
            if nargin<5
                specifiedFolderPath = obj.FilePath;
            end
            
            runInfo=obj;
            obj = obj.constructRunInfo(runInfo,specifiedFolderPath);
        end
        
    end%methods
end%class