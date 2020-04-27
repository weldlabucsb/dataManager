function outSatisfiers = checkCondition(obj,var,condition) 
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

                satisVals = runVals(runVals>=lowerBound & runVals<=upperBound);
            else
                %A single element condition
                el = str2double(commaSplit{jj});
                if ismember(el,runVals)
                    satisVals = el;
                else
                    satisVals = [];
                end
            end
            allSatisVals = vertcat(allSatisVals,satisVals);
        end

        outSatisfiers = sort(unique(allSatisVals));

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
    else
        warning(['The condition ' condition ' was ignored because the variable ' var ' was neither a char or number somehow'])
    end %checking type of property (numeric or char)
end
