clearvars;                         % Clear all variables from the workspace
close all;                         % Close all open figures

% Read in file
[filename, filepath] = uigetfile('*.csv');     % Open a dialog box so you can choose a wav file
input_file = fullfile(filepath, filename);     % Create the filename
data = csvread(input_file, 1, 0 );

% Assign data from file to local variables, t for time, y for amplitude
t = data(:, 1);
y = data(:, 2);

Fs = 1.0/mean(diff(t)); % Compute the average sampling frequency

% Subtract the DC content of the signal. If you care about the DC 
% content, comment out the following line:
y = y - mean(y);

% compute the PSD of the signal
[p,f] = periodogram(y, [],[],Fs);  % Periodogram method

% if the frequency content of your signal is essentially constant in time, 
% it may be preferable to use Welch's method in the commented out line 
% below. Please talk to your Lab Prof or one of the Lab Managers for details. 

% [p, f] = pwelch(y, [], [], [], Fs); %Welch's method

%%
% plot the result!
figure;
plot(f, p);
title(['PSD of ',filename]);
axis([0 Fs/2 0 inf]);
xlabel('Frequency (Hz)');
ylabel('Amplitude');
improvePlot;



