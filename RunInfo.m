classdef RunInfo
    %A class to hold information about each run
    %   A collection of information about each run and the file path to the
    %   run data so that data can be loaded for further analysis.
    
    properties
        RunID
        SeriesID
        RunType
        
        CitadelDir
        FilePath
        RunFolder %Folder title
        RunNumber %Char number
       
        Month 
        Day    
        
        p1064LattDepths %Vector of numerical values
        s915LattDepths  %Vector of numerical values
        LatticeHoldTimes   %Vector of numerical values
        
        KDCal915         %double
        
        Comments
        
        emptyElementFlag %To indicate
    end
    
    methods
        function obj = RunInfo(CSVTableLine,citadelDir)
            %Populates the properties from the input one row table
            %CSVTableLine that is expected to be generated from a readtable
            %command acted on a csv file.  Assumes that readtable has been
            %used to make all outputs cellarrays with strings.  Multiple
            %values should be separated with ; in the original csv (e.g. for multple depts)
            %Example call CSVTableLine = readtable('RunInfoTable.csv','Format',repmat('%s',[1,10]),'TextType','char','Delimiter',',')

            obj.CitadelDir = citadelDir;
            obj.emptyElementFlag=0;
            
            
            % Direct loading of properties provided in csv file
            obj.Month = tabUnpackNum(CSVTableLine.Month);
            obj.Day = tabUnpackNum(CSVTableLine.Day);
            
            obj.SeriesID = tabUnpackChar(CSVTableLine.SeriesID);
            obj.RunType = tabUnpackChar(CSVTableLine.RunType);
            
            obj.RunFolder = tabUnpackChar(CSVTableLine.RunFolder);
            
            obj.p1064LattDepths = tabUnpackNum(CSVTableLine.p1064LattDepths);
            obj.s915LattDepths = tabUnpackNum(CSVTableLine.s915LattDepths);
            obj.LatticeHoldTimes = tabUnpackNum(CSVTableLine.LatticeHoldTimes);
            
            obj.KDCal915 = tabUnpackNum(CSVTableLine.KDCal915);
            
            obj.Comments = tabUnpackChar(CSVTableLine.Comments);
            
            
            % Generated properties
            if iscell(CSVTableLine.RunFolder)
                runFold = CSVTableLine.RunFolder{1};
            else
                runFold = CSVTableLine.RunFolder;
            end
            
            
            splitRunName = split(runFold,' ');
            obj.RunNumber = splitRunName{1};
            
            obj.FilePath = makeFilePath(citadelDir, '2020', obj.Month , obj.Day , obj.RunFolder);
            
            obj.RunID = makeRunID(obj.Month,obj.Day,obj.SeriesID,obj.RunType,obj.RunNumber);
       
            obj.emptyElementFlag = checkForEmptyElem(obj);
        end
        
        function outFlag = checkForEmptyElem(obj) 
            %Redefine here as a member function after construction
            %Ignores empty comments
            outFlag = checkForEmptyElem(obj);
        end
        
        function nonZeroSub = checkForNonZeroSubset(obj,conditionsCellArray)
            %Returns 1 if the conditions given are satisfied by at least
            %one atomcloud in the dataset.  (Note, assumes that only one 
            %variable was changed each run.)
            numConditions = length(conditionsCellArray)/2;
            for ii=1:numConditions
                var = conditionsCellArray{2*ii-1};
                condition = conditionsCellArray{2*ii};  
                
                satisfiers = checkCondition(obj,var,condition);
                
                if isempty(satisfiers)
                    nonZeroSub = false;
                    return
                end
            end
            nonZeroSub = true;
        end
        
        function outputStruct = conditionalInfo(obj,conditionsCellArray)
            %Generates a struct of the properties that satisfy the
            %conditions given.
            %    The conditions should be provided in a cell array with an
            %    even number of entries of the form {'property1','condition1','property2','condition2',...}
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
            
            % Iterating through the conditions and checking which elements
            % satisfy the conditions
            numConditions = length(conditionsCellArray)/2;
            for ii=1:numConditions
                var = conditionsCellArray{2*ii-1};
                condition = conditionsCellArray{2*ii};  
                
                satisfiers = checkCondition(obj,var,condition);
                outputStruct.(var) = satisfiers;
            end %checking each condition
            
        end
        
        function outputTable = conditionalConstructionTable(obj,conditionsCellArray)
            %Generates a single line table of the form used to construct
            %this object (i.e. CSVTableLine in the constructor function 
            %obj = RunInfo(CSVTableLine,citadelDir)).  However, only the
            %values satisfying the provided conditions are included in the
            %table.
            %    The conditions should be provided in a cell array with an
            %    even number of entries of the form {'property1','condition1','property2','condition2',...}
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
            
            %Check length(conditionsCellArray) is a multiple of 2
            assert(mod(length(conditionsCellArray),2)==0,...
                'Conditions were not given as pairs of variables and possible values')
            
            %Initialize output table
            tableElements = {'Month','Day','SeriesID','RunType','RunFolder','p1064LattDepths',...
                's915LattDepths','LatticeHoldTimes','KDCal915','Comments'};
            outputTable = table('Size',size(tableElements),...
                'VariableType',repelem({'cell'},length(tableElements)),...
                'VariableNames',tableElements);
            
            %Fill output table with all data as is
            
            outputTable.Month = num2str(obj.Month);
            outputTable.Day = num2str(obj.Day);
            outputTable.SeriesID = obj.SeriesID;
            outputTable.RunType = obj.RunType;
            outputTable.RunFolder = obj.RunFolder;
            
            outputTable.p1064LattDepths = convertNumArray2CellString(obj.p1064LattDepths);
            outputTable.s915LattDepths = convertNumArray2CellString(obj.s915LattDepths);
            outputTable.LatticeHoldTimes = convertNumArray2CellString(obj.LatticeHoldTimes);
            outputTable.KDCal915 = convertNumArray2CellString(obj.KDCal915);
            outputTable.Comments = obj.Comments;
         
            
            % Iterating through the conditions and checking which elements
            % satisfy the conditions
            numConditions = length(conditionsCellArray)/2;
            for ii=1:numConditions
                var = conditionsCellArray{2*ii-1};
                condition = conditionsCellArray{2*ii};  
                
                satisfiers = checkCondition(obj,var,condition);
                if isnumeric(satisfiers)
                    outputTable.(var) = convertNumArray2CellString(satisfiers);
                else
                    outputTable.(var) = {satisfiers};
                end

            end %checking each condition
        end %MethodFnc
        
    end %Methods
end %Class def

function out = tabUnpackChar(tabElem)
    if iscell(tabElem)
        tabElem = tabElem{1};
    end
    out = tabElem;
end 
function out = tabUnpackNum(tabElem)
    if iscell(tabElem)
        tabElem = tabElem{1};
    end
    if isempty(tabElem)
        out = [];
        disp('EMPTY ELEM')
    else
        out = str2double(split(tabElem,';'));
    end
end

function [filePath] = makeFilePath(citadelDir,year,month,day,runFolder)
    cMonth = num2str(month);
    if length(cMonth)<2
        cMonth = ['0' cMonth];
    end
    
    cDay = num2str(day);
    if length(cDay)<2
        cDay = ['0' cDay];
    end
    
    filePath = [citadelDir filesep... 
        'StrontiumData' filesep...
        year filesep...
        year '.' cMonth filesep...
        cMonth '.' cDay filesep...
        runFolder];
end

function outFlag = checkForEmptyElem(obj)   
    outFlag = 0;
    props = properties(obj);
    for iprop = 1:length(props)
      thisprop = props{iprop};

        if isempty(obj.(thisprop))
            if ~strcmp(thisprop,'Comments')
                outFlag = 1;
                return
            end
        end

    end
end

function [runID] = makeRunID(month,day,seriesID,runType,runNumber)

    cMonth = num2str(month);
    if length(cMonth)<2
        cMonth = ['0' cMonth];
    end
    
    cDay = num2str(day);
    if length(cDay)<2
        cDay = ['0' cDay];
    end
    
    runID = [cMonth '_'... 
        cDay '_'...
        'Series' seriesID '_'...
        runType '_'...
        'Run' runNumber];
end

function outCell = convertNumArray2CellString(numArray)
    cellString = '';
    if ~isempty(numArray)
        cellString = num2str(numArray(1));
    end
    for ii=2:length(numArray)
        cellString = [cellString ';' num2str(numArray(ii))];
    end
    outCell = {cellString};
end

function out = checkCondition(obj,var,condition)             
    %The property being checked is a number array
    if isnumeric(obj.(var))
        runVals = obj.(var);
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

        out = sort(unique(allSatisVals));

    %The property being checked is a char array
    elseif ischar(obj.(var))
        if strcmp(condition(1),'=')
            condition = condition(2:end);
            if strcmp(condition,obj.(var))
                out = obj.(var);
            else
                out = '';
            end
        else
            if contains(obj.(var),condition)
                out = obj.(var);
            else
                out = '';
            end
        end
    else
        warning(['The condition ' condition ' was ignored because the variable ' var ' was neither a char or number somehow'])
    end %checking type of property (numeric or char)
end