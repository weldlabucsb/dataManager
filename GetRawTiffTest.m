% To test the new get dark, light, atoms

close all

%% Loading up some data
numCols = 9; % To load the table as all strings, you must specify the number of columns.
infoTable = readtable('shortAutoConstrTestTable.csv','Format',repmat('%s',[1,numCols]),'TextType','char','Delimiter',',');

shorterInfoTable = infoTable(1:2,:);

dataDir = '/Volumes/WeldLab/StrontiumData';

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
autoGenData = autoGenData.autoConstruct(shorterInfoTable,dataDir,ncVars,includeVars,excludeVars);

autoGenDataSubset = RunDataLibrary();
autoGenDataSubset = autoGenDataSubset.libraryConstruct(autoGenData,{'VVA915_Er','0.008'});

firstRunData = autoGenDataSubset.RunDatas{1};


customROI = [250,280,265,290];
% myCLim = [200,330];

type='atoms';
[atomDataMatrices,tiffFiles,ROI]=firstRunData.getRawTiffData(type,false,customROI);

fig = figure('Position',[40,40,1000,700]);
ax = axes();
imagesc(ax,ROI(3),ROI(1),atomDataMatrices{1});
daspect([1,1,1])
title('atoms')
colorbar(ax)
% ax.CLim = myCLim;

type='dark';
[darkDataMatrices,darkTiffFiles,ROI2]=firstRunData.getRawTiffData(type,false,customROI);

fig2 = figure('Position',[40,40,1000,700]);
ax2 = axes();
imagesc(ax2,ROI2(3),ROI2(1),darkDataMatrices{1});
daspect([1,1,1])
title('dark')
colorbar(ax2)
% ax2.CLim = myCLim;


type='light';
[lightDataMatrices,lightTiffFiles,ROI3]=firstRunData.getRawTiffData(type,false,customROI);

fig3 = figure('Position',[40,40,1000,700]);
ax3 = axes();
imagesc(ax3,ROI3(3),ROI3(1),lightDataMatrices{1});
daspect([1,1,1])
title('light')
colorbar(ax3)
% ax3.CLim = myCLim;
