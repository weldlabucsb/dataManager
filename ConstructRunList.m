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

initialDir = uigetdir(starting_directory,'Please choose initial data folder');
finalDir = uigetdir(starting_directory,'Please choose final data folder');

