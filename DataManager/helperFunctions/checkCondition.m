function [outSatisfiers,iSatisIndices,linkedVars,linkedncVars] = checkCondition(obj,var,condition) 
    %See if the specified var (which could be a property of the obj, or a
    %field in obj.vars or obj.ncVars) satisfies the conditions given.  
    %
    %The function returns the satisfactory values.  Note that conditions on
    %char text are not expected to have multiple components.  
    %
    %    Conditions on char properties can be of two forms. Specify
    %    the condition with a char array.  If the char array begins
    %    with an '=' it will see if the property exactly matches the
    %    condition (ignoring the initial =).  If no '=' is at the 
    %    start, it will see if the property contains the char
    %    array.
    %
    %    Conditions on numeric properties can be a string of possible 
    %    values separated by commas 
    %    (e.g. {'LatticeHoldTime','0,1000,10000'} to see 
    %    which values in 0,1000,10000 are present in the
    %    information.)
    %    
    %    Numeric conditions can also have inclusive ranges separated by 'to'.  
    %    (e.g. {'LatticeHoldTime','0to1000'} will check for lattice hold
    %    times in the range 0 to 1000. 
    %
    %    Numeric conditions can be a combination of the above two
    %    specifiers, with ranges and values separated by commas 
    %    (e.g. {'LatticeHoldTime','0to1000,10000,15000to20000'})

    %Find where 'var' is
    if isprop(obj,var)
        varSpace = obj;
    elseif isfield(obj.vars,var)
        varSpace = obj.vars;
    elseif isfield(obj.ncVars,var)
        varSpace = obj.ncVars;
    end
    %The property being checked is a number array
    if isnumeric(varSpace.(var))
        runVals = varSpace.(var);
        allSatisVals = [];
        allSatisInds = false(size(runVals));

        %Parse condition
        commaSplit = split(condition,',');
        for jj=1:length(commaSplit)
            assert(count(commaSplit{jj},'to')<2,'Conditions must only contain at most one ''to'' to represent range.  Separate conditions must be separated by commas')
            if count(commaSplit{jj},'to')==1
                %A range condition
                rangeCond=split(commaSplit{jj},'to');
                lowerBound=str2double(rangeCond{1});
                upperBound=str2double(rangeCond{2});

                assert(lowerBound<=upperBound,'Range conditions must be expressed ''<LowerBound>to<UpperBound>'' ')
                
                satisInds = (runVals>=lowerBound & runVals<=upperBound);
                satisVals = runVals(satisInds);
            else
                %A single element condition
                el = str2double(commaSplit{jj});
                if ismember(el,runVals)
                    satisVals = el;
                    satisInds = runVals==el;
                else
                    satisVals = [];
                    satisInds = false(size(runVals));
                end
            end
            allSatisVals = union(allSatisVals,satisVals);
            allSatisInds = allSatisInds|satisInds;
            if size(allSatisVals,2)~=1
                allSatisVals = transpose(allSatisVals);
            end
        end

        outSatisfiers = allSatisVals;
        iSatisIndices = allSatisInds;
        
        

    %The property being checked is a char array
    elseif ischar(varSpace.(var))
        if strcmp(condition(1),'=')
            condition = condition(2:end);
            if strcmp(condition,varSpace.(var))
                outSatisfiers = varSpace.(var);
            else
                outSatisfiers = '';
            end
        else
            if contains(varSpace.(var),condition)
                outSatisfiers = varSpace.(var);
            else
                outSatisfiers = '';
            end
        end
        iSatisIndices = false(0); % empty logical array
    else
        warning(['The condition ' condition ' was ignored because the variable ' var ' was neither a char or number somehow'])
    end %checking type of property (numeric or char)
    
    
    % Check for linked vars (i.e. other variables that are functions of the variable that the condition is set on)
    % NOTE only checks for ncVars and vars (didn't want to deal with other properties possibly having the same inputs)
    linkedVars = {};
    linkedncVars = {};
    for ii = 1:2
        if ii==1
            varSpace2 = obj.vars;
        elseif ii==2
            varSpace2 = obj.ncVars;
        else
            error('Did not know how to set varSpace somehow...')
        end
        
        for cellVar2=transpose(fieldnames(varSpace2))
            var2 = cellVar2{1}; 
            if max(size(varSpace2.(var2)))>1
                % check that there is more than one value of this
                % var.  We don't care if it's one for the whole
                % set.  That would be taken care of later.
                if all(size(varSpace2.(var2))==size(varSpace.(var)))
                    % check that there are the same number of
                    % values in both
                    if ~strcmp(var,var2)
                        % check that we haven't found the same
                        % variable we started with.
                        if ii==1
                            linkedVars = horzcat(linkedVars,var2);
                        elseif ii==2
                            linkedncVars = horzcat(linkedncVars,var2);
                        end
                    end
                end
            end
        end
    end
    
end
