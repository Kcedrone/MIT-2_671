function [filenames, measurement, units, data] = load_CSV_file_custom(input_file)
% function [headers, data] = load_CSV_file(input_file)
% input_file is optional argument
% if no file is specified, UI prompt will open

    switch nargin
        case 0
            [fn, pn] = uigetfile('*.csv');
            filename = strcat(pn, fn);
            
        otherwise
            filename = input_file;
    end


% Read the column headers in the first line of the CSV file
fid = fopen(filename);
headers1 = fgetl(fid); % Will read as one line
headers2 = fgetl(fid); % Will read as one line
headers3 = fgetl(fid); % Will read as one line
fclose(fid);

% Separate the line into individual column headers based on comma separator
filenames = strsplit(headers1, ',');
measurement = strsplit(headers2, ',');
units = strsplit(headers3, ',');

% Read CSV file as data, but ignore the header
row_start = 4; % Starting from 4th row
col_start = 0; % Starting from 1st column
data=csvread(filename, row_start, col_start); 

[~, name, ~] = fileparts(filename);
fprintf('Finished loading file %s...\n', strrep(name, '.csv',''));

end

