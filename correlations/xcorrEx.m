function [ ] = xcorrEx( )

% An example file of how to use the xcorr function in Matlab.

% First, let's look at some random noise.  By definition, there should be
% no repeating pattern in the data.

ww = randn(1000,1);                   % generate random data
[c_ww,lags] = xcorr(ww,10,'coeff');   % calculate the autocorrelation
stem(lags,c_ww)                       % plot the correlation coeffecients

% notice a huge spike at 0.  Of course, the correlation is perfect with
% itself without any lag.  But as soon as you use a bit of delay, there is
% very little, if any, correlation
figure

% Now let's try a signal with high correlations, a sine wave
ww = sin(0:0.1:10*pi);
[c_ww, lags] = xcorr(ww,100,'coeff');
stem(lags,c_ww);

% Once again, strongly correlated at 0, but now strongly negatively
% correlated at a lag of pi and strongly positively correlated at a lag of
% 2pi, as we'd expect.

figure
% Now let's show how we can see delay.
wwBig = randn(1200,1);
ww1 = wwBig(1:1000);
ww2 = wwBig(200:1200);

[c_ww, lags] = xcorr(ww1,ww2);
stem(lags,c_ww);

% Notice poor correlation as expected for all but a single delay entry.
% This huge spike corresponds to a very high correlationm giving you what
% the delay was.

% Cross and auto correlation are good at helping you to see how closely two
% functions match each other for many possible delays.
end

