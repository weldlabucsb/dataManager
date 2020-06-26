function ConstructRunList

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
% initialDir = uigetdir(starting_directory,'Please choose initial data day folder');
% finalDir = uigetdir(starting_directory,'Please choose final data day folder');

%%%%%%%%%%%%%% for testing purposes %%%%%%%%%%%
initialDir = 'F:\StrontiumData\2019\2019.12\12.16';
finalDir = 'F:\StrontiumData\2020\2020.01\01.12';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%get datestr object MATLAB (nice because doing +1 increments the day
%without having to worry about getting months and years right)
tInit = getDatestr(initialDir);
tFin = getDatestr(finalDir);

%For each day get the collection of runs in that folder
Tarray = tInit:tFin;

for i = Tarray
end



    function [datestr] = getDatestr(directory) 
        %extract the matlab datestring object from the starting
        %directories. NOTE: Relies on the current datescheme we have in the
        %citadel. Like so: F:\StrontiumData\2019\2019.12\12.16
        Year = str2num(directory(length(directory)-12:length(directory)-9));
        Month = str2num(directory(length(directory)-4:length(directory)-3));
        Day = str2num(directory(length(directory)-1:length(directory)));
        
        datestr = datetime(Year,Month,Day);
    end

end