%Author: Max Prichard
%Date: 6/26/2020

% The purpose of this is to have someone only select the first and last
% files that they want to be included in a .csv file that lists relevant
% run parameters. For those who are familiar with the example files that
% Peter has given on the DataManager repo, this program aims to effectively
% automatically create a RunInfoTable with nothing but the starting and
% ending folder. 

%Which overall data library we want to consider (i.e. SR or LI data). Also
%needs to be adjusted to suit the file locations on someones specific
%computer

%starting_directory = "{your drive letter here}:\{Lithium Data __or__
%Strontium Data}"
starting_directory = "F:\StrontiumData";

%get the start and end directory TO THE DAY
% initialDir = uigetdir(starting_directory,'Please choose initial data folder');
% finalDir = uigetdir(starting_directory,'Please choose final data folder');

initialDir = 'F:\StrontiumData\2019\2019.12\12.16';
finalDir = 'F:\StrontiumData\2019\2019.12\12.24';


%extract start and end year and month and day
initYear = str2num(initialDir(length(initialDir)-12:length(initialDir)-9));
initMonth = str2num(initialDir(length(initialDir)-4:length(initialDir)-3));
initDay = str2num(initialDir(length(initialDir)-1:length(initialDir)));

finYear = str2num(finalDir(length(finalDir)-12:length(finalDir)-9));
finMonth = str2num(finalDir(length(finalDir)-4:length(finalDir)-3));
finDay = str2num(finalDir(length(finalDir)-1:length(finalDir)));

%make datestr object MATLAB (nice because doing +1 increments the day
%without having to worry about getting months and years right)
tInit = datetime(initYear,initMonth,initDay);
tFin = datetime(finYear,finMonth,finDay);

%then, start making the CSV file for the runs that you want to keep. 

