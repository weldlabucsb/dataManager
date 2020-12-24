classdef RunDataLibrary<LibraryCatalog
    %A collection of RunData objects.  It has the same properties as the
    %LibraryCatalogClass (it is a subclass), so it is very similar to the 
    %RunInfoLibrary class but it contains a cell array (RunDatas) of 
    %RunData objects associated with all of the data.  
    %
    %   The atomdata is stored as a cell array within the RunData objects,
    %   but if you want a single large combined atomdata, you 
    %   can generate it as using the gen1Atomdata method function.
    %   
    %   The RunDataLibrary can be generated from an existing
    %   RunInfoLibrary using .libraryConstruct, or it can be generated 
    %   from a table using .tableConstruct in a similar fashion to 
    %   RunInfoLibrary.tableConstruct(...)
    
    properties
        RunDatas
    end
    
    methods
        function obj = RunDataLibrary(description)
            %Constructed with a text description of the contents.  RunInfo
            %is stored in the library using either the "tableConstruct"
            %method of the "libraryConstruct" method.
            obj@LibraryCatalog();
            if nargin>0
                obj.Description = description;
            end
            
            obj.RunDatas = {};
        end
        
        
        
        function obj = libraryConstruct(obj,library,conditionsCellArray,specifiedFolderPaths)
            %Fill out the RunDataLibrary object from either a
            %RunInfoLibrary or a different RunDataLibrary (given as library).
            
            %   specifiedFolderPaths is a cell array of folderpaths for
            %   each atomdata.  It is in case you do not have a connection
            %   to the citadel or if you stored the atomdata.mat files
            %   locally for some reason.  It must be the same length as the
            %   number of elements in the library.
            
            isSpecifiedPaths = true;
            if nargin<3
                conditionsCellArray = {};
            end
            if nargin<4
                isSpecifiedPaths = false;
                specifiedFolderPaths = {};
            end
            
            if isa(library,'RunDataLibrary')
                [obj.RunDatas,obj.RunIDs,obj.RunProperties,~] = library.whichRuns(conditionsCellArray);  %RunData is a subclass of RunInfo, so it will work
                
            elseif isa(library,'RunInfoLibrary')
                if ~isempty(conditionsCellArray)
                    [runInfos,obj.RunIDs,~,satisInds] = library.whichRuns(conditionsCellArray);
                else
                    runInfos = library.RunInfos;
                    obj.RunIDs = library.RunIDs;
                end
                
                obj.RunDatas = cell(size(runInfos,1),1);
                
                if isSpecifiedPaths
                    specifiedFolderPaths = specifiedFolderPaths(satisInds);
                end
                
                for ii = 1:size(runInfos,1)
                    obj.RunDatas{ii} = RunData();
                    if isSpecifiedPaths
                        obj.RunDatas{ii} = obj.RunDatas{ii}.constructRunInfo(runInfos{ii},specifiedFolderPaths{ii});
                    else
                        obj.RunDatas{ii} = obj.RunDatas{ii}.constructRunInfo(runInfos{ii});
                    end
                    
                end
            else
                error('library input argument must either be of class RunDataLibrary or RunInfoLibrary.')
            end
            
            %Determine all of the properties
            obj = obj.determineRunProps(obj.RunDatas); 
        end
        
        
        
        function obj = tableConstruct(obj,table,dataDir,conditionsCellArray,ncVars,specifiedFolderPaths)
            %Construct the data library from a table generated from a CSV
            %(in the same style as RunInfoLibrary.tableConstruct)
            %   specifiedFolderPaths is a cell array of folderpaths for
            %   each atomdata.  It is in case you do not have a connection
            %   to the citadel or if you stored the atomdata.mat files
            %   locally for some reason.  It must be the same length as the
            %   number of elements in the library.
            
            runInfoLib = RunInfoLibrary();
            if nargin<5
                ncVars = {};
            end
            if nargin<4
                conditionsCellArray={};
            end
            runInfoLib = runInfoLib.tableConstruct(table,dataDir,conditionsCellArray,ncVars);
            if nargin<6
                %If no specifiedFolderPaths
                obj = obj.libraryConstruct(runInfoLib,{});
                %Conditions were already applied in making the runInfoLib
            else
                obj = obj.libraryConstruct(runInfoLib,{},specifiedFolderPaths);
            end
        end
        
        
        
        function obj = autoConstruct(obj,table,dataDir,ncVars,includeVars,excludeVars,specifiedFolderPath)
            %Completes construction of this library by identifying run
            %folders from the table object and calling their atomdata.mat
            %files to determine what variables changed among the sets of
            %runs
            %   
            %   table is a matlab table object with the following table elements
            %   'Year','Month','Day','SeriesID','RunType','RunFolder','Comments'
            %   You can add more table elements, which will be assumed to
            %   be either Cicero variables or non-Cicero variables.  Non-Cicero 
            %   variables must also be indicated in the ncVars cell array.
            %   
            %   dataDir is the directory to the directory (usually on the citadel) 
            %   that contains the data.  For example /Volumes/WeldLab/StrontiumData  
            %   or W:\StrontiumData.  It is ignored if you put a
            %   specifiedFolderPath cell array.
            %
            %   specifiedFolderPaths is a cell array of folderpaths for
            %   each atomdata.  It is in case you do not have a connection
            %   to the citadel or if you stored the atomdata.mat files
            %   locally for some reason.  It must be the same length as the
            %   number of elements in the library.
            %
            %   ncVars are "non-cicero vars."  ncVars is a cell array of
            %   the names of the non-cicero variables.  Use these if there
            %   are parameters varied over the set of runs that is NOT
            %   automatically kept track of by cicero.
            %
            %   includeVars is a cell array of variable names that
            %   you would like to be considered EVEN IF they are not varied
            %   over the runs of the data set.
            %
            %   excludeVars is a cell array of variables that you like NOT
            %   to be considered EVEN IF they are varied over the runs of
            %   the data set.
            
            if nargin<6
                excludeVars = {};
            end
            if nargin<5
                includeVars = {};
            end
            if nargin<4 
                ncVars = {};
            end
            
            
            % Constructing a library from the information given in the
            % table.  Mostly used to get the run folders.
            baseRunInfoLib = RunInfoLibrary();
            baseRunInfoLib = baseRunInfoLib.tableConstruct(table,dataDir,{},ncVars);
            
            
            % Starting to populate this RunDataLibrary objects
            obj.RunDatas = cell(length(baseRunInfoLib.RunInfos),1);
            obj.RunIDs = cell(length(baseRunInfoLib.RunInfos),1);
            
            % Just loading in the Atomdata first
            for ii=1:length(baseRunInfoLib.RunInfos)
                
                runInfo=baseRunInfoLib.RunInfos{ii};
                
                % Get the folder with atomdata.mat in it
                if (nargin<7)||(isempty(specifiedFolderPath))
                    checkIfAtomDataExists(runInfo.FilePath);
                    folderPath = runInfo.FilePath;
                else
                    checkIfAtomDataExists(specifiedFolderPath);
                    folderPath = specifiedFolderPath{ii};
                end
                
                
                obj.RunDatas{ii} = RunData();
                
                % Setting the RunData Properties from the runInfo
                % properties
                propsToFill = {'RunID', 'SeriesID', 'RunType', 'DataDir'...
                    'FilePath','RunFolder','RunNumber','Year','Month','Day','vars',...
                    'ncVars','Comments'};
                for cellProp=propsToFill
                    prop = cellProp{1};
                    obj.RunDatas{ii}.(prop) = runInfo.(prop);
                end
                
                obj.RunDatas{ii}.emptyElementFlag = false;
                
                % Loading atom data and storing in
                % obj.RunDatas{ii}.Atomdata
                disp(['    Loading atomdata from ' num2str(runInfo.Month) '/' num2str(runInfo.Day) '/' num2str(runInfo.Year) ' Run: ' runInfo.RunFolder])
                obj.RunDatas{ii}.Atomdata = load([folderPath filesep 'atomdata.mat']).atomdata;
                
                obj.RunIDs{ii} = runInfo.RunID;
            end
            
            % Determine what cicero variables are varied among the set of
            % runs
            changedVars = {}; % vars that are changed over the set of runs.
            cicSeqChangeVars = {};  % Variables that were changed in the sequence change (used to make sure you only get one warning about it)
            
            % Using the first atomdata or the first run datas to initialize
            % all of the variables.
            allVars = fieldnames(obj.RunDatas{1}.Atomdata(1).vars);
            
            for jj = 2:length(obj.RunDatas{1}.Atomdata)
                for cVar = transpose(...
                        fieldnames(obj.RunDatas{1}.Atomdata(jj).vars))
                    var = cVar{1};
                    
                    if obj.RunDatas{1}.Atomdata(jj).vars.(var) ~= obj.RunDatas{1}.Atomdata(1).vars.(var)
                        % If this atomdata var value is not equal to the
                        % first one
                        if ~ismember(var,changedVars)
                            changedVars = vertcat(changedVars,var);
                        end
                    end
                end
            end
            
            for ii = 2:length(obj.RunDatas)
                prevAllVars = allVars;
                allVars = union(...
                            prevAllVars,...
                            fieldnames(obj.RunDatas{ii}.Atomdata(1).vars),...
                            'stable');
                if size(allVars,2)~=1
                    allVars = transpose(allVars);
                end
                
                % Checking if a variable was added or not
                if length(prevAllVars)<length(allVars)
                    addedVars = setdiff(allVars,prevAllVars);
                    if size(addedVars,1)~=1
                        addedVars = transpose(addedVars);
                    end
                    for cellcvar = addedVars
                        % for loop in case more than 1 changed var
                        cvar = cellcvar{1};
                        if ~ismember(cvar,cicSeqChangeVars)
                            cicSeqChangeVars=vertcat(cicSeqChangeVars,cvar);
                            warning(['The variable ' cvar ' was either added or removed to the cicero sequence over the course of this data taking.'])
                            disp(obj.RunDatas{ii}.RunID)
                            changedVars = vertcat(changedVars,cvar);
                        end  
                    end
                end
                if length(fieldnames(obj.RunDatas{ii}.Atomdata(1).vars))<length(allVars)
                    addedVars = setdiff(allVars , fieldnames(obj.RunDatas{ii}.Atomdata(1).vars));
                    if size(addedVars,1)~=1
                        addedVars = transpose(addedVars);
                    end
                    for cellcvar = addedVars
                        % for loop in case more than 1 changed var
                        cvar = cellcvar{1};
                        if ~ismember(cvar,cicSeqChangeVars)
                            cicSeqChangeVars=vertcat(cicSeqChangeVars,cvar);
                            warning(['The variable ' cvar ' was either added or removed to the cicero sequence over the course of this data taking.'])
                            changedVars = vertcat(changedVars,cvar);
                        end  
                    end
                end
            end
            
            
            for ii = 2:length(obj.RunDatas)
            % Iterating through atomdata and checking if the value
            % has changed from the first one.
                for jj = 1:length(obj.RunDatas{ii}.Atomdata)
                    for cVar = transpose(...
                            fieldnames(obj.RunDatas{ii}.Atomdata(jj).vars))
                        var = cVar{1};
                        if ~ismember(var, cicSeqChangeVars)
                            % If its a variable that is in some runs and
                            % not others, we skip it to avoid an error
                            % accessing a nonexistant var.
                            if obj.RunDatas{ii}.Atomdata(jj).vars.(var) ~= obj.RunDatas{1}.Atomdata(1).vars.(var)
                                % If this atomdata var value is not equal to the
                                % first one
                                if ~ismember(var,changedVars)
                                    changedVars = vertcat(changedVars,var);
                                end
                            end
                        end
                    end
                end
            end
                
            
            % At this point, we know which variables are changed over the
            % data sets.  This is stored in changedVars.  Next we loop
            % through the changed Vars and gather them into the
            % LibraryCatalog properties of RunDataLibrary.
            
            % Manually add the includeVars and remove the excludeVars
            varsOfInterest = union(includeVars,changedVars,'stable');
            varsOfInterest = setdiff(varsOfInterest,excludeVars,'stable');
            
            if size(varsOfInterest,1)~=1
                varsOfInterest = transpose(varsOfInterest);
            end
            
            for cVar=varsOfInterest
                cicVar = cVar{1};
                runInfoVar = inverseTranslateVarName(cicVar);
                
                for ii = 1:length(obj.RunDatas)
                    ignoreFlag=false;
                    [varVals,isSC] = specialCondCiceroValToRunInfo(cicVar,obj.RunDatas{ii});
                    if isSC
                        obj.RunDatas{ii}.vars.(runInfoVar) = varVals;
                    else
                        if ~isfield(obj.RunDatas{ii}.vars , runInfoVar)
                            atomdata = obj.RunDatas{ii}.Atomdata;
                            adVars = [atomdata.vars];
                            if isfield(atomdata(1).vars,cicVar)
                                varVals = unique([adVars.(cicVar)]);
                            else
                                varVals = [];
                            end
                        elseif isempty(  obj.RunDatas{ii}.vars.(runInfoVar)  )
                            atomdata = obj.RunDatas{ii}.Atomdata;
                            adVars = [atomdata.vars];
                            if isfield(atomdata(1).vars , cicVar)
                                varVals = unique([adVars.(cicVar)]);
                            else
                                varVals = [];
                            end
                        else
                            disp(['Ignoring values of ' cicVar ' in the atom data and instead using what is specified in the original table (under variable ' runInfoVar ')'])
                            ignoreFlag = true;
                        end

                        if size(varVals,2)>1
                            varVals=transpose(varVals);
                        end
                        
                        if ~ignoreFlag
                            obj.RunDatas{ii}.vars.(runInfoVar) = varVals;
                        end
                    end % special condition
                end %iter through RunDatas
            end % iter through variables of interest
            
            % Determine the collective run properties
            [obj,~] = determineRunProps(obj,obj.RunDatas);
            
        end
    end%methods
end%classdef

% function cellOfAtomdata = loadAllAtomdata(runInfoLib,specifiedFolderPath)
%     %Creates a cell array of atomdata structs corresponding to those
%     %identified in the runInfoLib (based on the runInfoLib.RunInfos).
%     %If the FilePaths in runInfoLib.RunInfos{ii}.FilePath are wrong for
%     %some reason (for example, if you have the atomdata stored locally or 
%     %are not connected to the citadel), you may specify a cell array of
%     %alternate file paths in specifiedFolderPath, where each file path in
%     %this cell array is a directory that contains the appropriate
%     %atomdata.mat file.
% 
%     
% end