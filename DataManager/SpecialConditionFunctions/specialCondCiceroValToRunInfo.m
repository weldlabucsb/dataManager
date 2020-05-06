function [varVals,isSC] = specialCondCiceroValToRunInfo(cicVar,runData)
%specialCondition to make RunInfo vars from cicero vars, in case there is
%some issue in the data taking that requires changing the recorded cicero
%values to an accurate value.

isSC=false;
varVals = [];

switch cicVar
    case {'VVA915_Er'}
        %A special condition because the KD915 calibration was wrong in
        %Cicero by a factor of 1.25 for several runs
        isSC=true;
        atomdata = runData.Atomdata;
        
        if ~isfield(runData.vars,'VVA915_Er')
            adVars = [atomdata.vars];
            %Determining real atomdata VVA915_Er values with a corrected
            %calibration that is stored in runInfo
            varVals = unique([adVars.Lattice915VVA]*(runData.ncVars.KDCal915));
        elseif isempty(runData.vars.VVA915_Er)
            adVars = [atomdata.vars];
            %Determining real atomdata VVA915_Er values with a corrected
            %calibration that is stored in runInfo
            varVals = unique([adVars.Lattice915VVA]*(runData.ncVars.KDCal915));
        else
            disp('Ignoring VVA915_Er as it appears in the atom data and instead using what is specified in the table')
            varVals = runData.vars.VVA915_Er;
        end
        
        if size(varVals,2)~=1
            varVals=transpose(varVals);
        end
end

end

