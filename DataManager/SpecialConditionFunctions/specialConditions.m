function [satisAD,isSC] = specialConditions(var,runInfo,atomdata)
%Defines special conditions for certain variables.  If a special condition
%is defined in this function, 'isSC' is set to true to indicate that a
%special condition exists and the 'satisAD' array of booleans can be used
%to trim the atomdata to only the atomdata elements that satisfy the
%special contion.  If no special condition, 'isSC' is set to false, and satisAD is set to
%an empty array.

isSC=false;
satisAD = [];

% DEFINE YOUR SPECIAL CONDITIONS HERE

switch var
    case {'VVA915_Er'}
        %A special condition because the KD915 calibration was wrong in
        %Cicero by a factor of 1.25 for several runs
        isSC=true;

        desiredVals = runInfo.vars.VVA915_Er;
        
        adVars = [atomdata.vars];
        %Determining real atomdata VVA915_Er values with a corrected
        %calibration that is stored in runInfo
        atomdataVals = [adVars.Lattice915VVA]*(runInfo.ncVars.KDCal915);
        
        tol = 5*10^(-3);
        satisAD = false(size(atomdataVals));
        for ii=1:length(desiredVals)
            satisThisVal = abs(atomdataVals-desiredVals(ii))<tol;
            satisAD = satisAD|satisThisVal;
        end
        
%         if all(~satisAD)
%             disp([runInfo.RunID ' BY VAR ' var])
%             disp('desiredVals')
%             disp(desiredVals)
%             disp('atomdataVals')
%             disp(atomdataVals)
%         end
end


end

