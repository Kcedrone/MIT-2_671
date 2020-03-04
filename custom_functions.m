% Function example

sample1 = [2,3,5,4,7,8,6,3];
sample2 = [1,1,1,1,5,8,3,3,3];

%% Repetitive blocks of code
% There's a risk when you copy-paste that you forget to update all the
% variable names of inputs and/or outputs. Moreover, adding a new stat for
% each sample is tedious. 
mu1 = mean(sample1);
sd1 = std(sample1, 0);
n1 = length(sample1);

mu2 = mean(sample2);
sd2 = std(sample2, 0);
n2 = length(sample2);

%% Using a function to factor out the common code
[mu1, sd1, n1] = common_stats(sample1);
[mu2, sd2, n2] = common_stats(sample2);

function [mu, sd, n] = common_stats(sample)
    mu = mean(sample);
    sd = std(sample, 0);
    n = length(sample);
end