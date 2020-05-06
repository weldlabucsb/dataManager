numCols = 9; % To load the table as all strings, you must specify the number of columns.
infoTable = readtable('shortAutoConstrTestTable.csv','Format',repmat('%s',[1,numCols]),'TextType','char','Delimiter',',');

citadelDir = '/Volumes/WeldLab';

p=genpath('DataManager'); %the DataManager folder must be in the current working folder for this to work, but you could do a variant on this if you save DataManager somewhere else.
oldpath = addpath(p);

% (A check for you that your directory exists according to Matlab:)
if ~exist(citadelDir,'dir')
    error(['The directory (folder).' citadelDir ' does not exist'])
end
    
ncVars = {'KDCal915','ImagingPowerVVA'}; 
includeVars = {'VVA1064_Er'};
excludeVars = {'IterationCount','IterationNum'};

autoGenData = RunDataLibrary();
autoGenData = autoGenData.autoConstruct(infoTable,citadelDir,ncVars,includeVars,excludeVars);