clearvars;                         % Clears all variables from the workspace
close all;                         % Closes all open figures

% Read in file
[filename, filepath] = uigetfile('*.csv');     % Opens a dialog box so you can choose a CSV file
input_file = fullfile(filepath, filename);     % Creates the filename
data = csvread(input_file, 1, 0 );             % Reads the file starting from the second line (ignores header line)

% Assign data from file to local variables, t for time, y for amplitude
t = data(:, 1);
y = data(:, 2);

Fs = 1.0/mean(diff(t)); % Compute the average sampling frequency

% Subtract the mean value of the y-data to eliminate the peak in the PSD at
% frequency = 0 (DC). If you care about the DC frequency content, remove
% this line of code!

y=y-mean(y); 

% compute the PSD using the periodogram method
[p,f] = periodogram(y, [],[],Fs);  

% if the frequency content of your signal is essentially constant in time, 
% it may be preferable to use Welch's method in the commented out line 
% below. Please talk to your Lab Prof or one of the Lab Managers for details. 

% [p, f] = pwelch(y, [], [], [], Fs); %Welch's method

%% plot the result!

fname_for_title = strrep(filename, '_', '\_'); % Replace underscores with \_ so they appear correctly

figure;
plot(f, p);
title(['PSD of ', fname_for_title]); 
axis([0 Fs/2 0 inf]);
xlabel('Frequency (Hz)');
ylabel('Amplitude');
improvePlot;

%% 
% Now integrate the PSD and normalize

IntPSD = cumtrapz(f, p); 

% If desired, normalize by the total integral, so that the normalized
% integrated PSD has values between 0 and 1. (If not desired, use IntPSD
% instead of normIntPSD.

normIntPSD = IntPSD / IntPSD(end); 

%% 
% plot the normalized integrated PSD

figure;
plot(f, normIntPSD);
title(['Norm Int PSD of ', fname_for_title]); 
axis([0 Fs/2 0 inf]);
xlabel('Frequency (Hz)');
ylabel('Amplitude');
improvePlot;





