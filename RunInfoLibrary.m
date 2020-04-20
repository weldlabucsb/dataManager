classdef RunInfoLibrary
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
        Description  % A character array to describe this library
        
        RunIDs   % A cell array of all of the run IDs in the collection of RunInfos
        RunProperties % A struct of all of the variables considered in the collection
        
    end
    
    methods
        function obj = RunInfoLibrary(description)
            %Constructed with a text description of the contents.  RunInfo
            %is stored in the library using either the "tableConstruct"
            %method of the "libraryConstruct" method.
            obj.Description = description;
        end
        
        function outputArg = tableConstruct(obj,table,citadelDir,conditionsCellArray)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
            error('Under Construction')
        end
        
        function outputArg = libraryConstruct(obj,library,conditionsCellArray)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
            error('Under Construction')
        end
        
        function [cellOfRunInfo,listRunIDs] = whichRuns(obj,conditionsCellArray)
            % Determines which runs in the library satisfy the conditions
            % given in the conditionsCellArry.  Returns a cell array of 
            % RunInfo (cellofRunInfo) as well as a cell of RunIDs
            % (listRunIDs).  The contents of both outputs are runs that
            % satisfy the conditions
            
            error('Under Construction')
        end
    end
end

