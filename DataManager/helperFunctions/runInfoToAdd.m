function [outRunInfo,outRunID]=runInfoToAdd(runInfo,conditionsCellArray)
    %Returns empty cells if no subset of runInfo satisfies the conditions
    %in the conditionsCellArry
    %
    %Returns an appropriate RunInfo or RunInfoSubset object and associated
    %run ID depending on whether the conditions are satisfied by all data
    %in the run or just some of it.
    if ~runInfo.isNonZeroSubset(conditionsCellArray)
        %If the conditions are not met by this run
        outRunInfo = {};
        outRunID = {};
    else
        subRunInfo = RunInfoSubset(runInfo,conditionsCellArray);
        if runInfoCompare(runInfo,subRunInfo)
            %If the subRun is identical to the full run
            outRunInfo = runInfo;
            outRunID = runInfo.RunID;
        else
            outRunInfo = subRunInfo;
            outRunID = subRunInfo.RunID;
        end
    end
end