classdef RunInfo
    %A class to hold information about each run
    %   A collection of information about each run and the file path to the
    %   run data so that data can be loaded for further analysis.
    
    properties
        RunID
        SeriesID
        RunType
        
        DataDir
        FilePath
        RunFolder %Folder title
        RunNumber %Char number
       
        Year
        Month 
        Day    
        
        vars
        ncVars %Non cicero vars
        
        Comments
        
        emptyElementFlag %To indicate
    end
    
    methods
        function obj = RunInfo(CSVTableLine,dataDir,ncVars)
            %Populates the properties from the input one row table
            %CSVTableLine that is expected to be generated from a readtable
            %command acted on a csv file.  Assumes that readtable has been
            %used to make all outputs cellarrays with strings.  Multiple
            %values should be separated with ; in the original csv (e.g. for multple depts)
            %Example call CSVTableLine = readtable('RunInfoTable.csv','Format',repmat('%s',[1,10]),'TextType','char','Delimiter',',')
            %
            %   dataDir is the directory for this machine that contains the
            %   desired data (e.g. /Volumes/WeldLab/StrontiumData on my machine)
            %
            %   ncVars are an optional input cell array of variables that
            %   are not stored by cicero.  It is of the form {'var1','var2',...}
            %   The strings in ncVars should be elements of the table CSVTableLine
            
            if nargin==0
                tableElements = {'Year','Month','Day','SeriesID','RunType','RunFolder','Comments'};
                CSVTableLine=table('Size',size(tableElements),...
                    'VariableType',repelem({'cellstr'},length(tableElements)),...
                    'VariableNames',tableElements);
                dataDir='';
                ncVars={};
            end
            if nargin<3
                ncVars={};
            end
            obj.DataDir = dataDir;
            obj.emptyElementFlag=0;
            
            
            % Direct loading of properties provided in csv file
            if any(strcmp(CSVTableLine.Properties.VariableNames,'Year'))
                obj.Year = tabUnpackNum(CSVTableLine.Year);
            else
                warning('No year specified.  Assuming current year.')
                obj.Year = num2str(datetime('now').Year);
            end
            obj.Month = tabUnpackNum(CSVTableLine.Month);
            obj.Day = tabUnpackNum(CSVTableLine.Day);
            
            if any(strcmp(CSVTableLine.Properties.VariableNames,'SeriesID'))
                obj.SeriesID = tabUnpackChar(CSVTableLine.SeriesID);
            else
                obj.SeriesID = '';
            end
            
            if any(strcmp(CSVTableLine.Properties.VariableNames,'RunType'))
                obj.RunType = tabUnpackChar(CSVTableLine.RunType);
            else
                obj.RunType = '';
            end
            
            obj.RunFolder = tabUnpackChar(CSVTableLine.RunFolder);
            
            if size(ncVars,1)>1
                notVars = horzcat(transpose(properties(obj)),transpose(ncVars));
            else
                notVars = horzcat(transpose(properties(obj)),ncVars);
            end
            
            obj.vars=struct();
            obj.ncVars=struct();
            for colVar=CSVTableLine.Properties.VariableNames
                if all(~ismember(notVars,colVar{1}))
                    obj.vars.(colVar{1}) = tabUnpack(CSVTableLine.(colVar{1}));
                elseif any(ismember(ncVars,colVar{1}))
                    obj.ncVars.(colVar{1}) = tabUnpack(CSVTableLine.(colVar{1}));
                end
            end
            
            
            obj.Comments = tabUnpackChar(CSVTableLine.Comments);
            
            
            % Generated properties
            if iscell(CSVTableLine.RunFolder)
                runFold = CSVTableLine.RunFolder{1};
            else
                runFold = CSVTableLine.RunFolder;
            end
            
            
            splitRunName = split(runFold,' ');
            obj.RunNumber = splitRunName{1};
            
            obj.FilePath = makeFilePath(obj.DataDir , obj.Year, obj.Month , obj.Day , obj.RunFolder);
            
            obj.RunID = makeRunID(obj.Year,obj.Month,obj.Day,obj.SeriesID,obj.RunType,obj.RunNumber);
       
            obj.emptyElementFlag = checkForEmptyElem(obj);
        end
        
        
        
        function obj = writeRunInfo(obj,CSVTableLine,dataDir,ncVars)
            %A clone of the constructor for loading the RunInfo with data
            %in the case that it was initialized empty.
            %
            %Populates the properties from the input one row table
            %CSVTableLine that is expected to be generated from a readtable
            %command acted on a csv file.  Assumes that readtable has been
            %used to make all outputs cellarrays with strings.  Multiple
            %values should be separated with ; in the original csv (e.g. for multple depts)
            %Example call CSVTableLine = readtable('RunInfoTable.csv','Format',repmat('%s',[1,10]),'TextType','char','Delimiter',',')
            %
            %   ncVars are an optional input cell array of variables that
            %   are not stored by cicero.  It is of the form {'var1','var2',...}
            %   The strings in ncVars should be elements of the table CSVTableLine
            
            if nargin==0
                tableElements = {'Year','Month','Day','SeriesID','RunType','RunFolder','Comments'};
                CSVTableLine=table('Size',size(tableElements),...
                    'VariableType',repelem({'cellstr'},length(tableElements)),...
                    'VariableNames',tableElements);
                dataDir='';
                ncVars={};
            end
            if nargin<3
                ncVars={};
            end
            obj.DataDir = dataDir;
            obj.emptyElementFlag=0;
            
            
            % Direct loading of properties provided in csv file
            if any(strcmp(CSVTableLine.Properties.VariableNames,'Year'))
                obj.Year = tabUnpackNum(CSVTableLine.Year);
            else
                warning('No year specified.  Assuming current year.')
                obj.Year = num2str(datetime('now').Year);
            end
            obj.Month = tabUnpackNum(CSVTableLine.Month);
            obj.Day = tabUnpackNum(CSVTableLine.Day);
            
            if any(strcmp(CSVTableLine.Properties.VariableNames,'SeriesID'))
                obj.SeriesID = tabUnpackChar(CSVTableLine.SeriesID);
            else
                obj.SeriesID = '';
            end
            
            if any(strcmp(CSVTableLine.Properties.VariableNames,'RunType'))
                obj.RunType = tabUnpackChar(CSVTableLine.RunType);
            else
                obj.RunType = '';
            end
            
            obj.RunFolder = tabUnpackChar(CSVTableLine.RunFolder);
            
            if size(ncVars,1)>1
                notVars = horzcat({'Year','Month','Day','SeriesID','RunType','RunFolder','RunID','Comments'},transpose(ncVars));
            else 
                notVars = horzcat({'Year','Month','Day','SeriesID','RunType','RunFolder','RunID','Comments'},ncVars);
            end
                
            obj.vars=struct();
            obj.ncVars=struct();
            for colVar=CSVTableLine.Properties.VariableNames
                if all(~ismember(notVars,colVar{1}))
                    obj.vars.(colVar{1}) = tabUnpack(CSVTableLine.(colVar{1}));
                elseif any(ismember(ncVars,colVar{1}))
                    obj.ncVars.(colVar{1}) = tabUnpack(CSVTableLine.(colVar{1}));
                end
            end
            
            
            obj.Comments = tabUnpackChar(CSVTableLine.Comments);
            
            
            % Generated properties
            if iscell(CSVTableLine.RunFolder)
                runFolder = CSVTableLine.RunFolder{1};
            else
                runFolder = CSVTableLine.RunFolder;
            end
            
            
            splitRunName = split(runFolder,' ');
            obj.RunNumber = splitRunName{1};
            
            obj.FilePath = makeFilePath(obj.DataDir, obj.Year, obj.Month , obj.Day , obj.RunFolder);
            
            obj.RunID = makeRunID(obj.Year,obj.Month,obj.Day,obj.SeriesID,obj.RunType,obj.RunNumber);
       
            obj.emptyElementFlag = checkForEmptyElem(obj);
        end
        
        
        
        function outFlag = checkForEmptyElem(obj) 
            %Check if the RunInfo (or RunInfoSubset) has an empty element
            outFlag = checkForEmptyElem(obj);
        end
        
        
        
        function nonZeroSub = isNonZeroSubset(obj,conditionsCellArray)
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
            partialConditionedRunInfo = obj;
            for ii=1:numConditions
                var = conditionsCellArray{2*ii-1};
                condition = conditionsCellArray{2*ii};
                
                % Checking conditions and getting linked variables.
                [satisfiers,satisInds,linkedVars,linkedncVars] = checkCondition(partialConditionedRunInfo,var,condition);
                if isnumeric(satisfiers)
                    outputStruct.(var) = satisfiers;
                    %Updating values in partially conditioned object for
                    %the sake of possible linked variables
                    if isfield(partialConditionedRunInfo.vars , var)
                        partialConditionedRunInfo.vars.(var) = satisfiers;
                    elseif isfield(partialConditionedRunInfo.ncVars , var)
                        partialConditionedRunInfo.ncVars.(var) = satisfiers;
                    end
                    
                    %Updating linked vars
                    for cVar2=linkedVars
                        var2 = cVar2{1};
                        
                        valsBefore = partialConditionedRunInfo.vars.(var2);
                        satisfiers2 = valsBefore(satisInds);
                        
                        partialConditionedRunInfo.vars.(var2) = satisfiers2;
                        outputStruct.(var2) = satisfiers2;
                    end
                    
                    for cVar2 = linkedncVars
                        var2 = cVar2{1};
                        
                        valsBefore = partialConditionedRunInfo.ncVars.(var2);
                        satisfiers2 = valsBefore(satisInds);
                        
                        partialConditionedRunInfo.ncVars.(var2) = satisfiers2;
                        outputStruct.(var2) = satisfiers2;
                    end
                else
                    outputStruct.(var) = {satisfiers};
                end

            end %checking each condition
        end
        
        
        
        function outputTable = conditionalConstructionTable(obj,conditionsCellArray)
            %Generates a single line table of the form used to construct
            %this object (i.e. CSVTableLine in the constructor function 
            %obj = RunInfo(CSVTableLine,dataDir)).  However, only the
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
            tableElements = horzcat(...
                {'Year','Month','Day','SeriesID','RunType','RunFolder'},...
                transpose(fieldnames(obj.vars)),...
                transpose(fieldnames(obj.ncVars)),...
                {'Comments'});
            outputTable = table('Size',size(tableElements),...
                'VariableType',repelem({'cell'},length(tableElements)),...
                'VariableNames',tableElements);
            
            %Fill output table with all data as is
            outputTable.Year = num2str(obj.Year);
            outputTable.Month = num2str(obj.Month);
            outputTable.Day = num2str(obj.Day);
            if ~isempty(obj.SeriesID)
                outputTable.SeriesID = obj.SeriesID;
            else
                outputTable.SeriesID = cell(1,1);
            end
            if ~isempty(obj.RunType)
                outputTable.RunType = obj.RunType;
            else
                outputTable.RunType = cell(1,1);
            end
            outputTable.RunFolder = obj.RunFolder;
            
            if ~isempty(fieldnames(obj.vars))
                for aVar=transpose(fieldnames(obj.vars))
                    outputTable.(aVar{1}) = convertNumArray2CellString(obj.vars.(aVar{1}));
                end
            end
            
            if ~isempty(fieldnames(obj.ncVars))
                for aVar=transpose(fieldnames(obj.ncVars))
                    outputTable.(aVar{1}) = convertNumArray2CellString(obj.ncVars.(aVar{1}));
                end
            end
            
            if ~isempty(obj.Comments)
                outputTable.Comments = obj.Comments;
            else
                outputTable.Comments = cell(1,1);
            end
            
            % Iterating through the conditions and checking which elements
            % satisfy the conditions
            numConditions = length(conditionsCellArray)/2;
            partialConditionedRunInfo = obj;
            for ii=1:numConditions
                var = conditionsCellArray{2*ii-1};
                condition = conditionsCellArray{2*ii};
                
                % Checking conditions and getting linked variables.
                [satisfiers,satisInds,linkedVars,linkedncVars] = checkCondition(partialConditionedRunInfo,var,condition);
                if isnumeric(satisfiers)
                    outputTable.(var) = convertNumArray2CellString(satisfiers);
                    %Updating values in partially conditioned object for
                    %the sake of possible linked variables
                    if isfield(partialConditionedRunInfo.vars , var)
                        partialConditionedRunInfo.vars.(var) = satisfiers;
                    elseif isfield(partialConditionedRunInfo.ncVars , var)
                        partialConditionedRunInfo.ncVars.(var) = satisfiers;
                    end
                    
                    %Updating linked vars
                    for cVar2=linkedVars
                        var2 = cVar2{1};
                        
                        valsBefore = partialConditionedRunInfo.vars.(var2);
                        satisfiers2 = valsBefore(satisInds);
                        
                        partialConditionedRunInfo.vars.(var2) = satisfiers2;
                        outputTable.(var2) = convertNumArray2CellString(satisfiers2);
                    end
                    
                    for cVar2 = linkedncVars
                        var2 = cVar2{1};
                        
                        valsBefore = partialConditionedRunInfo.ncVars.(var2);
                        satisfiers2 = valsBefore(satisInds);
                        
                        partialConditionedRunInfo.ncVars.(var2) = satisfiers2;
                        outputTable.(var2) = convertNumArray2CellString(satisfiers2);
                    end
                else
                    outputTable.(var) = {satisfiers};
                end

            end %checking each condition
        end %MethodFnc
        
    end %Methods
end %Class def

function out = tabUnpack(tabElem)
    if iscell(tabElem)
        tabElem = tabElem{1};
    end
    if isempty(tabElem)
        out = [];
        return
    end
    
    tryNum = str2double(split(tabElem,';'));
    if any(isnan(tryNum))
        % Does not seem to be numeric
        out = tabElem;
    else
        out = tryNum;
    end
end

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
    else
        out = str2double(split(tabElem,';'));
    end
end

function [filePath] = makeFilePath(dataDir,year,month,day,runFolder)
    cYear = num2str(year);
    if length(cYear)==2
        cYear = ['20' cYear];
    end

    cMonth = num2str(month);
    if length(cMonth)<2
        cMonth = ['0' cMonth];
    end
    
    cDay = num2str(day);
    if length(cDay)<2
        cDay = ['0' cDay];
    end
    
    filePath = [dataDir filesep...
        cYear filesep...
        cYear '.' cMonth filesep...
        cMonth '.' cDay filesep...
        runFolder];
end

function outFlag = checkForEmptyElem(obj)   
    outFlag = 0;
    ignoreProps={'generatingConditons','Comments','fullRunInfo'};
    props = properties(obj);
    for iprop = 1:length(props)
      thisprop = props{iprop};

        if isempty(obj.(thisprop))
            if all(~strcmp(thisprop,ignoreProps))
                outFlag = 1;
                return
            end
        end

    end
end

function [runID] = makeRunID(year,month,day,seriesID,runType,runNumber)
    
    cYear = num2str(year);
    if length(cYear)==2
        cYear = ['20' cYear];
    end

    cMonth = num2str(month);
    if length(cMonth)<2
        cMonth = ['0' cMonth];
    end
    
    cDay = num2str(day);
    if length(cDay)<2
        cDay = ['0' cDay];
    end
    
    runID = [cYear '_'...
        cMonth '_'... 
        cDay];
    
    if ~isempty(seriesID)
        runID = horzcat(runID,'_','Series', seriesID);
    end
    
    if ~isempty(runType)
        runID = horzcat(runID,'_', runType);
    end
    
    runID = horzcat(runID,'_','Run-', runNumber);
end



