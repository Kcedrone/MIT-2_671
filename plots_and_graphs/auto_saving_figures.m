close all;
clear all;

% Make some data to play with
x = 0:0.1:10.0; x=x(:);
y = 2.*x + 3 + 0.5*randn(length(x),1) ;

% Prompt the user for the filename (before plot covers command line)
filename_out = input('Enter the output filename and press return:  ', 's');

% Plot the data
h = figure;
plot(x, y, 'b.');
improvePlot;

timestamp = datestr(now, 'yyyymmdd_HHMMSS');

% Save the figure
filename_out = [filename_out, '_', timestamp]; % append timestamp to the filename
print(h, filename_out, '-dpng');