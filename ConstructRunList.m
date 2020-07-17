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
%SHOULD BE LITHIUM OR STRONTIUM DATA, eg:
% starting_directory = 'F:\StrontiumData';
starting_directory = uigetdir('.','Please choose StrontiumData or LithiumData directory on your system.');

%Extract whether it was lithium or strontium data for use later. Need to
%make sure that there aren't any reserved characters here or it will cause
%problems down the line when we save the csv file
indices = find(starting_directory == '\' | starting_directory == '.');
starting_dir_name = starting_directory(indices(end)+1:end);

%get the start and end directory TO THE DAY. If you want to do a certain
%month range, then go into that month's folder and choose the first day
%folder that is in it. 
initialDir = uigetdir(starting_directory,'Please choose initial data day folder');
finalDir = uigetdir(starting_directory,'Please choose final data day folder');

% %%%%%%%%%%%%%% for testing purposes %%%%%%%%%%%
% initialDir = 'F:\StrontiumData\2020\2020.03\03.07';
% finalDir = 'F:\StrontiumData\2020\2020.03\03.15';
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%get datestr object MATLAB (nice because doing +1 increments the day
%without having to worry about getting months and years right)
tInit = getDatestr(initialDir);
tFin = getDatestr(finalDir);
% keyboard
%For each day get the collection of runs in that folder
Tarray = tInit:tFin;
run_titles = string([]);
for ii = Tarray
    %getting all of the files and subdirectories that are part of the
    %current directory
    subdirs = dir(getDirectory(ii,starting_directory));
    %then, using logical indexing, only take the ones that are actually
    %subdirectories
    ok_ones = logical([subdirs.isdir].*[~strcmp({subdirs.name},'.')].*[~strcmp({subdirs.name},'..')]);
    subdirs = subdirs(ok_ones);
    %append the run directory titles into the run_titles matrix. This is
    %going to be output as a CSV a little later in the process. Note I have
    %to do a bit of gymnastics with cells here to make sure that the
    %character arrays aren't concatenated before they are written into the
    %run_titles string array. 
    s = size(run_titles);
    run_titles(s(1)+1,1:(length(subdirs)+1)) = string([getDirectory(ii,starting_directory) string({subdirs.name})]);
end
% keyboard
% writematrix(run_titles',strcat('.\',starting_dir_name,'_',string(tInit),'_',string(tFin),'_','runtitles.csv'));

%now to check for the MEGAKD tag that usually shows the kicked atom
%experiments. 

log_mat = contains(run_titles,'MEGAKD');
keyboard;

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

function [directory]  = getDirectory(datein,base_directory)
    %basically just the inverse of the above function, where I want to
    %output the string form of the directory given a datestring input
    %and the base_directory, which will change depending on which
    %computer this is run off of. 
    y = num2str(year(datein),'%04d');
    m = num2str(month(datein),'%02d');
    d = num2str(day(datein),'%02d');
    

    directory = string([base_directory '\' y '\' y '.' m '\' m '.' d]);
end
