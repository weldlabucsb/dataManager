classdef LibraryCatalog
    %A collection of RunIDs and the range of run properties.  Not used as a
    %class by itself, but is a superclass of RunInfoLibrary and
    %RunDataLibrary so that those libraries have the associated catalog
    %objects.
    
    properties
        Description  % A character array to describe this library

        RunProperties % A struct of all of the variables considered in the collection
        
        RunIDs   % A cell array of all of the run IDs in the collection of RunInfos
    end
    
    methods
        function obj = LibraryCatalog()
            obj.Description = '';
            obj.RunProperties = struct();
            obj.RunIDs = {};
        end
        
        
        
        function [obj,runPropsStruct] = determineRunProps(obj,runInfos)
            %Searches through all of the RunInfos to determine all of the
            %available run information values.

            runProperties=struct();
            runProperties.vars = struct();
            runProperties.ncVars = struct();

            ignoredProps = {'RunID','vars','ncVars','Comments','emptyElementFlag','FullRunInfo','GeneratingConditions','Atomdata'};

            for ii=1:length(runInfos)
                for cellProp = transpose(properties(runInfos{ii}))
                    prop = cellProp{1};

                    if ~ismember(prop,ignoredProps)
                        %If not ignored
                        if isnumeric(runInfos{ii}.(prop))
                            if ~isfield(runProperties,prop)
                                runProperties.(prop)=runInfos{ii}.(prop);
                            else
                                runProperties.(prop)=union(runProperties.(prop),runInfos{ii}.(prop));
                                if size(runProperties.(prop),2)~=1
                                    runProperties.(prop) = transpose(runProperties.(prop));
                                end
                            end
                        elseif ischar(runInfos{ii}.(prop))
                            if ~isfield(runProperties,prop)
                                runProperties.(prop)={runInfos{ii}.(prop)};
                            else
                                runProperties.(prop)=union(runProperties.(prop),{runInfos{ii}.(prop)});
                                if size(runProperties.(prop),2)~=1
                                    runProperties.(prop) = transpose(runProperties.(prop));
                                end
                            end
                        else
                            error(['The property element ',prop, ' is somehow neither a char or numeric variable'])
                        end
                    end %Check not ignored prop
                end %Check for unique properties

                for cellVarStructName = {'vars','ncVars'}
                    varStructName = cellVarStructName{1};
                    RunInfoVarStruct = runInfos{ii}.(varStructName);
                    for cellVar=transpose(fieldnames(RunInfoVarStruct))
                        var = cellVar{1};

                        if isnumeric(RunInfoVarStruct.(var))
                            if ~isfield(runProperties.(varStructName),var)
                                runProperties.(varStructName).(var)=RunInfoVarStruct.(var);
                            else
                                runProperties.(varStructName).(var)=...
                                    union(...
                                        runProperties.(varStructName).(var),...
                                        RunInfoVarStruct.(var));
                                if size(runProperties.(varStructName).(var),2)~=1
                                    runProperties.(varStructName).(var) = transpose(runProperties.(varStructName).(var));
                                end
                            end
                        elseif ischar(RunInfoVarStruct.(var))
                            if ~isfield(runProperties.(varStructName),var)
                                runProperties.(varStructName).(var)={RunInfoVarStruct.(var)}; %Needs to be in cell
                            else
                                runProperties.(varStructName).(var)=...
                                    union(...
                                        runProperties.(varStructName).(var),...
                                        {RunInfoVarStruct.(var)});
                                if size(runProperties.(varStructName).(var),2)~=1
                                    runProperties.(varStructName).(var) = transpose(runProperties.(varStructName).(var));
                                end
                            end
                        else
                            error(['The variable ',var, ' is somehow neither a char or numeric variable'])
                        end %Adding to properties struct based on conditions
                    end%Looping through the variables in the runInfo
                end %Doing either vars or ncVars
            end
            
            obj.RunProperties = runProperties;
            if nargout>1
                runPropsStruct = runProperties;
            end
        end
        
        
        
        function [cellOfRunObjects,listRunIDs,rangeRunProperties,satisInds] = whichRuns(obj,conditionsCellArray)
            % Determines which runs in the library satisfy the conditions
            % given in the conditionsCellArry.  Returns a cell array of 
            % RunInfo (cellofRunInfo) as well as a cell of RunIDs
            % (listRunIDs).  The contents of both outputs are runs that
            % satisfy the conditions
            
            if isa(obj,'RunDataLibrary')
                runInfos = 'RunDatas';
                oldRunDatas = obj.RunDatas;
            elseif isa(obj,'RunInfoLibrary')
                runInfos = 'RunInfos';
            else
                error('library input argument must either be of class RunDataLibrary or RunInfoLibrary.')
            end
            
            cellOfRunInfo=cell(size(obj.(runInfos),1),1);
            listRunIDs=cell(size(obj.RunIDs,1),1);
            for ii = 1:size(obj.(runInfos),1)
                runInfo = obj.(runInfos){ii};
               
                %Outputs all RunInfoSubsets, so in the RunData case, you
                %need to use these RunInfoSubsets to generate the RunData
                [cellOfRunInfo{ii},listRunIDs{ii}]=runInfoToAdd(runInfo,conditionsCellArray);
            end
            
            %Getting rid of the empty cells
            nonEmptyCells = ~cellfun('isempty', cellOfRunInfo);
            
            if isa(obj,'RunDataLibrary')
                %Dragging along run data to avoid needing to reload from
                %the citadel.
                satisOldRunDatas = oldRunDatas(nonEmptyCells);
            end
            cellOfRunInfo = cellOfRunInfo(nonEmptyCells);
            if strcmp(runInfos,'RunDatas')
                cellOfRunObjects = cell(size(cellOfRunInfo,1),1);
                %Generating RunData objects from the satisfactory RunInfo
                %objects
                for ii=1:size(cellOfRunInfo,1)
                    cellOfRunObjects{ii} = RunData();
                    cellOfRunObjects{ii} = cellOfRunObjects{ii}.constructRunInfo(cellOfRunInfo{ii},'',satisOldRunDatas{ii}.Atomdata);
                end
            else
                cellOfRunObjects = cellOfRunInfo;
            end
            listRunIDs = listRunIDs(nonEmptyCells);
            
            %Determining the all of the properties that are varied over in
            %the library
            [~,rangeRunProperties] = obj.determineRunProps(cellOfRunInfo);
            
            satisInds=nonEmptyCells;
        end
    end  % end methods
    
end

