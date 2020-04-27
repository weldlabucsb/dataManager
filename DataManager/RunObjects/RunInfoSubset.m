classdef RunInfoSubset<RunInfo
    %A class of run info for subsets of given runs.
    %   This is a subclass of RunInfo, so it has all of the properties and
    %   methos of RunInfo, but also contains additional information about 
    %   the full run for comparison to see what data was removed in
    %   creating the subset.
    
    properties
        FullRunInfo %Contains the full run info object.  This will sometimes be empty if the subset was generated from a table
        GeneratingConditions  %conditionsCellArray given for the the construction of this subset
    end
    
    methods
        function obj = RunInfoSubset(runInfo,conditionsCellArray)
            %Generate an object of run info for the subclass
            %    The inputs are (1) the runInfo object that the subset is being
            %    taken from and (2) the conditionsCellArry that are used to 
            %    specify which data is included in the subset.
            %
            %    The conditionsCellArray is a cell array of the same form
            %    used in the conditionalConstructionTable is of the same
            %    form as that used in the conditionalInfo method function
            %    of the RunInfo class (see " help RunInfo.conditionalConstructionTable"
            %    for more information).  Specifically, it is of the form 
            %    {'property1','condition1','property2','condition2',...}
            if nargin==0
                runInfo=RunInfo();
                
                conditionsCellArray={};
                
                subTable = makeEmptyGeneratingTable;
                
                citadelDir='';
                ncVarFields={};
            else
                if nargin<2
                    conditionsCellArray={};
                end
                if ~(runInfo.isNonZeroSubset(conditionsCellArray))&&(~isempty(conditionsCellArray))
                    warning(['A run info subset was generated from run ', runInfo.RunID ,' that has an empty element.  There is no data in the run that satisfies all of the conditions, and so likely should not be considered.'])
                end

                if ~isempty(conditionsCellArray)
                    assert(any(size(conditionsCellArray)==1),'conditionsCellArray must be either a row cell array or a column cell array.')
                end
                subTable = runInfo.conditionalConstructionTable(conditionsCellArray);
                citadelDir = runInfo.CitadelDir;
                ncVarFields=fieldnames(runInfo.ncVars);
            end
            

            %Using superclass constructor with a table generated that has
            %conditions placed on it.
            obj@RunInfo(subTable,citadelDir,ncVarFields);
            
            
            
            if nargin>0
                obj.FullRunInfo = runInfo;
                if ~strcmp(obj.RunID(end-6:end),'_Subset')
                    isSame = runInfoCompare(runInfo,obj);
                    isPropSubset = ~isSame;
                    if isPropSubset
                        obj.RunID = [obj.RunID '_Subset'];
                    end
                end

                if ~isprop(runInfo,'GeneratingConditions')
                    obj.GeneratingConditions = conditionsCellArray;
                elseif isempty(obj.GeneratingConditions)
                    obj.GeneratingConditions = conditionsCellArray;
                else
                    warning('This is a run subset of a run subset, so two sets of generating conditions have been used.  All have been appended to the ''generatingConditions'' property.')

                    if size(runInfo.GeneratingConditions,1)==1
                        % If conditions given as a row
                        obj.GeneratingConditions = horzcat(runInfo.GeneratingConditions,conditionsCellArray);
                    elseif size(runInfo.GeneratingConditions,2)==1
                        % If conditions given as a column
                        obj.GeneratingConditions = horzcat(transpose(runInfo.GeneratingConditions),transpose(conditionsCellArray));
                    end
                end
            end
        end
            
        function obj = appendSubset(obj)
            if ~strcmp(obj.RunID(end-6:end),'_Subset')
                obj.RunID = [obj.RunID '_Subset'];
            end
        end
  
    end
end

