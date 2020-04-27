function [isSameRunInfo,differingElem] = runInfoCompare(runInfo1,runInfo2)
%Check if runInfo1 and runInfo2 are the same.  Useful for seeing if a run
%subset is a proper subset of the initial RunInfo.
%
%   isSameRunInfo is a boolean that is true if the two runInfos are the
%   same
%
%   differingElem is a string that indicates the first property of the 
%   runInfo that was found to be different between the two.
    
    numPropsToCheck = {'Month','Day'};
    for cellProp=numPropsToCheck
        prop = cellProp{1};
        if ~(runInfo1.(prop)==runInfo2.(prop))
            isSameRunInfo = false;
            differingElem = prop;
            return
        end
    end
    
    strPropsToCheck = {'SeriesID','RunType','RunFolder','FilePath'};
    for cellProp=strPropsToCheck
        prop = cellProp{1};
        if ~(strcmp(runInfo1.(prop),runInfo2.(prop)))
            isSameRunInfo = false;
            differingElem = prop;
            return
        end
    end
   
    
    ConcatAllVarsFields = vertcat(fieldnames(runInfo1.vars),fieldnames(runInfo2.vars));
    varPropsToCheck = transpose(unique(ConcatAllVarsFields));
    
    for cellProp=varPropsToCheck
        prop = cellProp{1};
        if (~isfield(runInfo1.vars,prop))||(~isfield(runInfo2.vars,prop))
            isSameRunInfo = false;
            differingElem = [prop,'; in vars'];
            return
        end
        if ~(length(runInfo1.vars.(prop))==length(runInfo2.vars.(prop)))
            isSameRunInfo = false;
            differingElem = [prop,'; in vars'];
            return
        end
        sortedRI1Prop = sort(runInfo1.vars.(prop));
        sortedRI2Prop = sort(runInfo2.vars.(prop));
        tol = 10^(-8);
        if any(abs(sortedRI1Prop-sortedRI2Prop)>tol)
            isSameRunInfo = false;
            differingElem = [prop,'; in vars'];
            return
        end
    end

    
    ConcatAllncVarsFields = vertcat(fieldnames(runInfo1.ncVars),fieldnames(runInfo2.ncVars));
    ncVarPropsToCheck = transpose(unique(ConcatAllncVarsFields));
    
    for cellProp=ncVarPropsToCheck
        prop = cellProp{1};
        if (~isfield(runInfo1.ncVars,prop))||(~isfield(runInfo2.ncVars,prop))
            isSameRunInfo = false;
            differingElem = [prop,'; in ncVars'];
            return
        end
        if ~(length(runInfo1.ncVars.(prop))==length(runInfo2.ncVars.(prop)))
            isSameRunInfo = false;
            differingElem = [prop,'; in ncVars'];
            return
        end
        sortedRI1Prop = sort(runInfo1.ncVars.(prop));
        sortedRI2Prop = sort(runInfo2.ncVars.(prop));
        tol = 10^(-8);
        if any(abs(sortedRI1Prop-sortedRI2Prop)>tol)
            isSameRunInfo = false;
            differingElem = [prop,'; in ncVars'];
            return
        end
    end
    
    isSameRunInfo = true;
    differingElem = '';
end

