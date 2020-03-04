clearvars;                         % Clear all variables from the workspace
close all;                         % Close all open figures

% Read in file
[filename, filepath] = uigetfile('*.wav');     % Open a dialog box so you can choose a wav file
input_file = fullfile(filepath, filename);     % Creates the filename
[y, Fs] = audioread(input_file);

% Subtract the DC content of the signal. If you care about the DC 
% content, comment out the following line:
y = y - mean(y);

% Compute the PSD of signal
[p,f] = periodogram(y, [],[],Fs);  % Periodogram method

% if the frequency content of your signal is essentially constant in time, 
% it may be preferable to use Welch's method in the commented out line 
% below. Please talk to your Lab Prof or one of the Lab Managers for details. 

% [p, f] = pwelch(y, [], [], [], Fs); %Welch's method

% plot the result!
figure;
plot(f, p);
title('PSD of Input Wavefile');
axis([0 Fs/2 0 inf]);
xlabel('Frequency (Hz)');
ylabel('Amplitude');
improvePlot;



