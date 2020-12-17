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
starting_directory = 'G:\StrontiumData';
% starting_directory = uigetdir('.','Please choose StrontiumData or LithiumData directory on your system.');

%Extract whether it was lithium or strontium data for use later. Need to
%make sure that there aren't any reserved characters here or it will cause
%problems down the line when we save the csv file
indices = find(starting_directory == filesep | starting_directory == '.');
starting_dir_name = starting_directory(indices(end)+1:end);

%get the start and end directory TO THE DAY. If you want to do a certain
%month range, then go into that month's folder and choose the first day
%folder that is in it. 
initialDir = uigetdir(starting_directory,'Please choose initial data day folder');
finalDir = uigetdir(starting_directory,'Please choose final data day folder');

% %%%%%%%%%%%%%% for testing purposes %%%%%%%%%%%
% initialDir = 'F:\StrontiumData\2020\2020.03\03.07';
% initialDir = 'G:\LithiumData\2019\2019.11\11.09';
% finalDir = 'F:\StrontiumData\2020\2020.03\03.15';
% finalDir = 'G:\LithiumData\2019\2019.11\11.14';
% finalDir = 'G:\LithiumData\2020\2020.03\03.22';
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%get datestr object MATLAB (nice because doing +1 increments the day
%without having to worry about getting months and years right)
tInit = getDatestr(initialDir);
tFin = getDatestr(finalDir);
% keyboard
%For each day get the collection of runs in that folder
Tarray = tInit:tFin;
run_titles = string([]);
run_dates = NaT(0);
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
%     keyboard;
    run_titles(1:(length(subdirs)+1),s(2)+1) = string([getDirectory(ii,starting_directory) string({subdirs.name})]);
    run_dates(1:(length(subdirs)+1),s(2)+1) = ii;
    disp([num2str(100*(find(Tarray==ii)/length(Tarray))) '% Done']);
end
keyboard

%If readable = true, then an additional, more human-readable csv is
%generated with columns of run folders that correspond to the data taken on
%a specific day. This is more useful for very large sets of data where a
%single column would be more difficult to parse.
readable = true;
if (readable)
    writematrix(run_titles,strcat('.', filesep ,starting_dir_name,'_',string(tInit),'_',string(tFin),'_','runtitlesREADABLE.csv'));
end

%for compatibility with the rest of datamanager, now I will remove the
%month folders from the list since they do not contain any data. This is
%the first column.
run_titles = run_titles(2:end,1:end);
run_dates = run_dates(2:end,1:end);
%remove missing entries (these are there since not all days have the same
%amount of runs taken.
log_ind = ~run_titles.ismissing;
run_titles = run_titles(log_ind);
run_dates = run_dates(log_ind);
%now to put the data in a good format. 
keyboard;
year_col = year(run_dates);
month_col = month(run_dates);
day_col = day(run_dates);
comments = strings(size(run_titles));
seriesID = strings(size(run_titles));
runType = strings(size(run_titles));

csv_output = [["Year";year_col] ["Month";month_col] ["Day";day_col] ["SeriesID";seriesID] ["RunType";runType] ["RunFolder";run_titles]];
%save the output in datamanager format
writematrix(csv_output,strcat('.', filesep ,starting_dir_name,'_',string(tInit),'_',string(tFin),'_','runtitles.csv'));
%then extract only the MEGAKD runs
megakdruns = run_titles(contains(run_titles,'MEGAKD','IgnoreCase',true));

keyboard;
%now to try and extract the run data from the folder names 
rundata = ["Run Title", "Lattice Depth", "T" , "Tau"]; 
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
    

    directory = string([base_directory filesep y filesep y '.' m filesep m '.' d]);
end
