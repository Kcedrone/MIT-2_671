% remove one or both of the next lines if you 
% do NOT want to clear your workspace and 
% close all previous figures

clear all;
close all;

% Select your CSV data file

[fn, pn] = uigetfile('*.csv');
filename = strcat(pn, fn);

%read the data

data = csvread(filename, 1, 0);

% Define L as the total number of points 
% Double check that it is correct for your file!

L = length(data)