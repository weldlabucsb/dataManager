classdef RunInfoSubset<RunInfo
    %A class of run info for subsets of given runs.
    %   This is a subclass of RunInfo, so it has all of the properties and
    %   methos of RunInfo, but also contains additional information about 
    %   the full run for comparison to see what data was removed in
    %   creating the subset.
    
    properties
        fullRunInfo %Contains the full run info object
        generatingConditons  %conditionsCellArray given for the the construction of this subset
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
             
            if ~(runInfo.checkForNonZeroSubset(conditionsCellArray))
                warning(['A run info subset was generated from run ', runInfo.RunID ,' that has an empty element.  There is no data in the run that satisfies all of the conditions, and so likely should not be considered.'])
            end
            
            assert(any(size(conditionsCellArray)==1),'conditionsCellArray must be either a row cell array or a column cell array.')
            
            %Using superclass constructor with a table generated that has
            %conditions placed on it.
            subTable = runInfo.conditionalConstructionTable(conditionsCellArray);
            citadelDir = runInfo.CitadelDir;
            obj@RunInfo(subTable,citadelDir);

            obj.fullRunInfo = runInfo;
            if ~strcmp(obj.RunID(end-6:end),'_Subset')
                obj.RunID = [obj.RunID '_Subset'];
            end
            
            if ~isprop(runInfo,'generatingConditons')
                obj.generatingConditons = conditionsCellArray;
            else
                warning('This is a run subset of a run subset, so two sets of generating conditions have been used.  All have been appended to the ''generatingConditons'' property.')
                
                if size(runInfo.generatingConditons,1)==1
                    % If conditions given as a row
                    obj.generatingConditions = horzcat(runInfo.generatingConditons,conditionsCellArray);
                elseif size(runInfo.generatingConditons,2)==1
                    % If conditions given as a column
                    obj.generatingConditions = vertcat(runInfo.generatingConditons,conditionsCellArray);
                end
            end
        end
    end
end

