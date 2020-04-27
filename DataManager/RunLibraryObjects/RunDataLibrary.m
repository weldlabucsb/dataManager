classdef RunDataLibrary<LibraryCatalog
    %A collection of RunData objects.  It has the same properties as the
    %LibraryCatalogClass (it is a subclass), so it is very similar to the 
    %RunInfoLibrary class but it contains a cell array (RunDatas) of 
    %RunData objects associated with all of the data.  
    %
    %   The atomdata is stored as a cell array within the RunData objects,
    %   but if you want a single large combined atomdata, you 
    %   can generate it as using the gen1Atomdata method function.
    %   
    %   The RunDataLibrary can be generated from an existing
    %   RunInfoLibrary using .libraryConstruct, or it can be generated 
    %   from a table using .tableConstruct in a similar fashion to 
    %   RunInfoLibrary.tableConstruct(...)
    
    properties
        RunDatas
    end
    
    methods
        function obj = RunDataLibrary(description)
            %Constructed with a text description of the contents.  RunInfo
            %is stored in the library using either the "tableConstruct"
            %method of the "libraryConstruct" method.
            obj@LibraryCatalog();
            if nargin>0
                obj.Description = description;
            end
            
            obj.RunDatas = {};
        end
        
        function obj = libraryConstruct(obj,library,conditionsCellArray,specifiedFolderPaths)
            %Fill out the RunDataLibrary object from either a
            %RunInfoLibrary or a different RunDataLibrary (given as library).
            
            %   specifiedFolderPaths is a cell array of folderpaths for
            %   each atomdata.  It is in case you do not have a connection
            %   to the citadel or if you stored the atomdata.mat files
            %   locally for some reason.  It must be the same length as the
            %   number of elements in the library.
            
            isSpecifiedPaths = true;
            if nargin<3
                conditionsCellArray = {};
            end
            if nargin<4
                isSpecifiedPaths = false;
                specifiedFolderPaths = {};
            end
            
            if isa(library,'RunDataLibrary')
                [obj.RunDatas,obj.RunIDs,obj.RunProperties,~] = library.whichRuns(conditionsCellArray);  %RunData is a subclass of RunInfo, so it will work
                
            elseif isa(library,'RunInfoLibrary')
                if ~isempty(conditionsCellArray)
                    [runInfos,obj.RunIDs,~,satisInds] = library.whichRuns(conditionsCellArray);
                else
                    runInfos = library.RunInfos;
                    obj.RunIDs = library.RunIDs;
                end
                
                obj.RunDatas = cell(size(runInfos,1),1);
                
                if isSpecifiedPaths
                    specifiedFolderPaths = specifiedFolderPaths(satisInds);
                end
                
                for ii = 1:size(runInfos,1)
                    obj.RunDatas{ii} = RunData();
                    if isSpecifiedPaths
                        obj.RunDatas{ii} = obj.RunDatas{ii}.constructRunInfo(runInfos{ii},specifiedFolderPaths{ii});
                    else
                        obj.RunDatas{ii} = obj.RunDatas{ii}.constructRunInfo(runInfos{ii});
                    end
                    
                end
            else
                error('library input argument must either be of class RunDataLibrary or RunInfoLibrary.')
            end
            
            
            %Determine all of the properties
            obj = obj.determineRunProps(obj.RunDatas);
            
        end
        function obj = tableConstruct(obj,table,citadelDir,conditionsCellArray,ncVars,specifiedFolderPaths)
            %Construct the data library from a table generated from a CSV
            %(in the same style as RunInfoLibrary.tableConstruct)
            %   specifiedFolderPaths is a cell array of folderpaths for
            %   each atomdata.  It is in case you do not have a connection
            %   to the citadel or if you stored the atomdata.mat files
            %   locally for some reason.  It must be the same length as the
            %   number of elements in the library.
            
            runInfoLib = RunInfoLibrary();
            if nargin<5
                ncVars = {};
            end
            if nargin<4
                conditionsCellArray={};
            end
            runInfoLib = runInfoLib.tableConstruct(table,citadelDir,conditionsCellArray,ncVars);
            if nargin<6
                %If no specifiedFolderPaths
                obj = obj.libraryConstruct(runInfoLib,{});
                %Conditions were already applied in making the runInfoLib
            else
                obj = obj.libraryConstruct(runInfoLib,{},specifiedFolderPaths);
            end
        end
        
        function outputArg = autoConstruct(obj,table,citadelDir,conditionsCellArray,specifiedFolderPath)
            %Completes construction of this library by identifying run
            %folders from the table object and calling their atomdata.mat
            %files to determine what variables changed among the sets of
            %runs
            error('Under Construction!')
        end
        
    end%methods
end%classdef

% function cellOfAtomdata = loadAllAtomdata(runInfoLib,specifiedFolderPath)
%     %Creates a cell array of atomdata structs corresponding to those
%     %identified in the runInfoLib (based on the runInfoLib.RunInfos).
%     %If the FilePaths in runInfoLib.RunInfos{ii}.FilePath are wrong for
%     %some reason (for example, if you have the atomdata stored locally or 
%     %are not connected to the citadel), you may specify a cell array of
%     %alternate file paths in specifiedFolderPath, where each file path in
%     %this cell array is a directory that contains the appropriate
%     %atomdata.mat file.
% 
%     
% end