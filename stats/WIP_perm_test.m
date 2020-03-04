clc; clearvars; close all;
% permutation test
tic
disp('Starting...');
group1 = [5,6,5,6,5,7,7];
group1 = [5,5,5,5,5,6];
group1 = normrnd(7, 3, [500, 1]);
group1 = normrnd(7, 3, [30, 1]);

group2 = [4,5,4,4,3,4,5,4];
group2 = [100, 100, 100, 100, 100, 100];
group2 = normrnd(4, 3, [500, 1]);
group2 = normrnd(4, 3, [30, 1]);

group1=group1(:);
group2=group2(:);

stat_test = @mean;
% stat_test = @median;
% stat_test = @(x)(prctile(x, 66) - prctile(x, 33));
% stat_test = @std;

f_g1 = stat_test(group1);
f_g2 = stat_test(group2);
delta = f_g1 - f_g2;

if delta < 0
    % Swap group1 and group2
    disp('Swap!');
    temp = group1;
    group1 = group2;
    group2 = temp;
end

f_g1 = stat_test(group1);
f_g2 = stat_test(group2);
delta = f_g1 - f_g2;

N_tests = 500000;

N1 = length(group1);
N2 = length(group2);
combined = [group1; group2];
N_combined = N1 + N2;
extreme_count = 0;
for i=1:N_tests
    random_shuffle = combined(randperm(N_combined));
    g1 = random_shuffle(1:N1);
    g2 = random_shuffle((N1 + 1):end);
    
    if stat_test(g1) - stat_test(g2) > delta
        extreme_count = extreme_count + 1;
    end
    
end
p_val = extreme_count/N_tests;

if p_val < 0.0001
    pval_fmt = '%.4e';
else
    pval_fmt = '%.4f';
end
output_str = sprintf(['f(g1)=%.2f, f(g2)=%.2f, diff(g1-g2)=%.2f, p=',pval_fmt], f_g1, f_g2, delta, p_val);
disp(output_str);

[h, tt_p_val] = ttest2(group1, group2, 'Vartype', 'unequal');
if tt_p_val < 0.0001
    tt_pval_fmt = '%.4e';
else
    tt_pval_fmt = '%.4f';
end
output_str2 = sprintf(['t-test p=',tt_pval_fmt],tt_p_val);
disp(output_str2);

toc

% function res = other_func(x, handle);
