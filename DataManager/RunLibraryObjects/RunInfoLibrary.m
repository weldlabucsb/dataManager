classdef RunInfoLibrary<LibraryCatalog
    %A collection of RunInfo and RunInfoSubset objects.  Used for
    %specifying what data to use for a given analysis, when that analysis
    %uses atomdata from multiple runs.
    %   
    %   The constructor does not load the run info.  It only attaches a
    %   description to the collection (if you include an input argument).
    %   Instead, to determine the set of RunInfo objects in this library, 
    %   use either: (1) RunInfoLibrary.tableConstruct which uses a csv
    %   style table of run info to generate a number of run info objects 
    %   (conditions can be used if not all of the runs in the csv table are
    %   desired), or (2) RunInfoLibrary.libraryConstruct which takes a different
    %   RunInfoLibrary object and uses it to generate a new library,
    %   possibly with conditions on which runs are included.
    
    properties
        RunInfos %A cell array of the RunInfo objects that form the libray
    end
    
    methods
        function obj = RunInfoLibrary(description)
            %Constructed with a text description of the contents.  RunInfo
            %is stored in the library using either the "tableConstruct"
            %method of the "libraryConstruct" method.
            obj@LibraryCatalog();
            if nargin>0
                obj.Description = description;
            end
            
            obj.RunInfos = {};
        end
        
        
        
        function [obj]=tableConstruct(obj,table,citadelDir,conditionsCellArray,ncVars)
            %Completes construction of this library by filling it out using
            %a Matlab table object (like one generated from reading a csv
            %file using:
            %readtable('RunInfoTable.csv','Format',repmat('%s',[1,10]),'TextType','char','Delimiter',',');
            %   
            %   table should be the table of run information from the csv
            %
            %   citadelDir should be a directory to the citadel
            %
            %   conditionsCellArray should be a cell array of conditions on
            %   the variables in the run info
            %
            %   ncVars are an input cell array of variables that
            %   are not stored by cicero.  It is of the form {'var1','var2',...}
            %   The strings in ncVars should be elements of the table
            %   CSVTableLine.

            if nargin<5
                ncVars={};
            end
            if nargin<4
                conditionsCellArray = {};
            end
            
            obj.RunInfos=cell(size(table,1),1);
            obj.RunIDs=cell(size(table,1),1);
            for ii = 1:size(table,1)
                runInfo = RunInfo(table(ii,:),citadelDir,ncVars);
                
                [obj.RunInfos{ii},obj.RunIDs{ii}]=runInfoToAdd(runInfo,conditionsCellArray);
                
            end
            
            %Getting rid of the empty cells
            nonEmptyCells = ~cellfun('isempty', obj.RunInfos);
            
            obj.RunInfos = obj.RunInfos(nonEmptyCells);
            obj.RunIDs = obj.RunIDs(nonEmptyCells);
            
            obj = obj.determineRunProps(obj.RunInfos);
        end
        
        
        
        function obj = libraryConstruct(obj,library,conditionsCellArray)
            %Completes construction of this library by filling it out using
            %a larger library that you are removing some of the runs from.
            
            if nargin<3
                conditionsCellArray = {};
            end
            
            obj.RunInfos=cell(size(library.RunInfos,1),1);
            obj.RunIDs=cell(size(library.RunInfos,1),1);
            for ii = 1:size(library.RunInfos,1)
                runInfo = library.RunInfos{ii};
                
                [obj.RunInfos{ii},obj.RunIDs{ii}]=runInfoToAdd(runInfo,conditionsCellArray);
            end
            
            %Getting rid of the empty cells
            nonEmptyCells = ~cellfun('isempty', obj.RunInfos);
            
            obj.RunInfos = obj.RunInfos(nonEmptyCells);
            obj.RunIDs = obj.RunIDs(nonEmptyCells);
            
            %Determining the all of the properties that are varied over in
            %the library
            obj = obj.determineRunProps(obj.RunInfos);
        end
        
    end
end

