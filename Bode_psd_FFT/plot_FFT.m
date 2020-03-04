function [freq, fft_amplitude] = plot_FFT(y, t) 

% This script is designed to run when you already have y and t defined in
% the workspace. 
%
% If you need to compute many FFTs for your Go Forth, you can convert this 
% script to a function by un-commenting the first and last lines of this m file.
% In that case, you may also wish to comment the lines of code that plot the
% results.

% Inputs
% y is input time series data vector
% t is the time vector corresponding to the y data

% Outputs
% As a script:      A plot of the FFT of the y data series
% As a function:    Frequency and amplitude of the FFT of the y data series

% Convert y and t to column vectors. 
% This is a habit that can avoid some unexpected behavior arising from 
% how MATLAB treats row vectors and column vectors
y = y(:);
t = t(:);
L = length(y);

% Make y have even number of entries. This is necessary for the way
% MATLAB computes the FFT
if mod(L, 2)            % If L is odd
    y = y(1:(end-1));   % Truncate the last value
    L = length(y);      % Update L
end

% Fs is sampling frequency (in Hz) of the y time series
% Here it is calculated from the mean difference between sample points.
% This works around the possibility of non-constant sample rate, which 
% should  not be a problem in Logger Pro but may be in other environments.
% An ideal solution would be 
Fs = 1./mean(diff(t));

% Subtract the mean value of the y-data to eliminate the peak in the PSD at
% frequency = 0 (DC). 

% Compute the (discrete) Fourier transform of the signal with the mean 
% value (DC component) subtracted from the signal. If you care about the DC
% frequency content, comment this line of code, and use Y = fft(y);
Y = fft(y-mean(y)); 

% Compute the (discrete) Fourier transform of the original signal.
% Y = fft(y);

% Compute the two-sided spectrum P2. This is the Fourier spectrum for
% negative and positive frequency. In most cases, only the positive
% frequency spectrum is physically relevant. 
P2 = abs(Y/L);

% Compute the single-sided positive-frequency spectrum P1 based on P2 and 
% the even-valued signal length L.
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% Define the frequency vector, freq, and the FFT amplitude, fft_amplitude. 
freq = Fs*(0:(L/2))/L;
fft_amplitude = P1;

% Plot the FFT amplitude (vertical axis) versus frequency (horizontal axis)
% Note the vertical axis units of an FFT are the same as the input data
% series, while the horizontal axis has units of frequency in Hz.

figure;
plot(freq, fft_amplitude) 
ylabel('FFT amplitude (input units)')
xlabel('Frequency (Hz)')
xlim([0, Fs/2]);
% the following script is used to create more professionally formatted
% plots, available on the 2.671 Wiki MATLAB page. Must be in the same
% directory as this code, or in your MATLAB path.

improvePlot; 



% end 