function atomdataVar = translateVarName(runInfoVar)
%In the case that the RunInfo.vars properties names were assigned
%differently than the cicero variable names in the atomdata of the given
%run, this function maps the RunInfo.vars to its corresponding cicero
%variable as stored in atomdata.vars

switch runInfoVar
    % PUT YOUR TRANSLATIONS HERE AS CASES
    otherwise
        atomdataVar = runInfoVar;
end

end

