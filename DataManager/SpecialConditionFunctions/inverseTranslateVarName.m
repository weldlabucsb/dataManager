function runInfoVar = inverseTranslateVarName(atomdataVar)
%THe inverse of translateVarName
%
%In the case that the RunInfo.vars properties names are assigned
%differently than the cicero variable names in the atomdata of the given
%run, this function maps the atomdata.vars to its corresponding cicero
%variable as stored in RunInfo.vars.

switch atomdataVar
    % PUT YOUR TRANSLATIONS HERE AS CASES
    otherwise
        runInfoVar = atomdataVar;
end

end