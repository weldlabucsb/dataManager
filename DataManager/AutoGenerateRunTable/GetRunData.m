function data_output_path = GetRunData(varargin,options)
% GETRUNDATA builds a RunDataLibrary from a datatable csv.
%
% Can be run with one or zero arguments. If provided, argument should be
% the path of the datatable csv. If not provided, choose from explorer. Can
% change default directory in line 34.
% 
% Options:
% 1. NumColumns (double) should match the number of columns in the csv.
% 2. DataDir (path string) the location of the experimental data (StrontiumData, LithiumData).
% 3. DataLibraryDescription (string) gets attached to the RunDataLibrary output.
% 4. DataFileName (string) is the filename of the output .mat file. DO NOT USE PERIODS IN THE FILENAME.
% 5. ncVars is a cell array of non-cicero variable names to be included in RunDatas.vars from columns in the datatable csv.
% 6. includeVars is a cell array of cicero variable names to be included in RunDatas.vars.
% 7. excludeVars is a cell array of cicero variable names to be excluded from RunDatas.vars
% 8. OpenOutputFolder (logical) toggles opening the output folder on completion.

arguments (Repeating)
   varargin 
end
arguments
    options.NumColumns (1,1) double = 6
    options.DataDir = 'E:\__Data\StrontiumData'
    % options.DataDir = 'X:\StrontiumData';
    options.DataLibraryDescription string = ['Data pulled on ' date]
    options.DataFileName string = ['Data_' date '.mat']
    options.ncVars = {};
    options.includeVars = {'VVA1064_Er','VVA915_Er','LatticeHold'};
    options.excludeVars = {'IterationCount','IterationNum','ImageTime','LogTime','PiezoModFreq'};
    options.OpenOutputFolder (1,1) logical = 1
    options.DefaultOutputDir string = "G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_data_loading\Data"
    options.OutputDir string = ""
end

% choose default output dir (only has effect if GetRunData run w/o first argument
% default_output_dir = pwd;

% check if DataDir exists
if ~exist(options.DataDir,'dir')
    error(['The directory (folder).' options.DataDir ' does not exist'])
    return
end

% make sure output filetype is .mat
fsplit = split(options.DataFileName,'.');
if fsplit{end} ~= "mat"
    disp('Output filename is not .mat format. Swapping extension to .mat.');
    if length(fsplit) > 1
        options.DataFileName = strcat( strjoin( fsplit(1:end-1) ), ".mat");
    else
        options.DataFileName = strcat( fsplit, ".mat");
    end
end

% If one input, use as path of datatable csv. Otherwise, choose file.
if length(varargin) == 1
    infoTablePath = varargin{1};
    l = split(infoTablePath,filesep);
    output_dir = strjoin( l(1:end-1), filesep );
elseif isempty(varargin)
    [infoTableName, output_dir] = uigetfile(...
        strcat(options.DefaultOutputDir,filesep,"*.csv"),...
        'Select the data table CSV.');
    if infoTableName == 0
       disp('No file selected. Cancelling.');
       return
    end
    infoTablePath = fullfile(output_dir,infoTableName);
end

if options.OutputDir ~= ""
    output_dir = options.OutputDir;
end

% by default, .mat is saved at location of csv
data_output_path = fullfile(output_dir, options.DataFileName);

% To load the table as all strings, you must specify the number of columns.
infoTable = readtable(infoTablePath,...
    'Format',repmat('%s',[1,options.NumColumns]),...
    'TextType','char',...
    'Delimiter',',');

Data = RunDataLibrary(options.DataLibraryDescription);
Data = Data.autoConstruct(...
    infoTable,...
    options.DataDir,...
    options.ncVars,...
    options.includeVars,...
    options.excludeVars);

% save the data
save(data_output_path,'Data');

if options.OpenOutputFolder
    if(ispc)
        winopen(data_output_path);
    end
end

end