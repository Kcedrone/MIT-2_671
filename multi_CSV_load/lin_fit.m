function [params, uParams] = lin_fit(x_data, y_data, doPlot)
% function [params, uParams] = lin_fit(x_data, y_data, doPlot)
% If doPlot = 1, function will plot raw data and linear fit

% Define the functional form of the fit
ft1 = fittype('a*x+b');

% The key to a good fit is good starting guesses
% When I don't know what the coefficients will be, I guess, run the fit
% once then run it again using the output of the first iteration and some 
% engineering judgment to select starting points for the second iteration.
a_guess = (max(y_data) - min(y_data)) / (max(x_data) - min(x_data)); 
b_guess = 0;

% Convert to column vectors
x_data=x_data(:);
y_data=y_data(:);

f1 = fit(x_data, y_data, ft1, 'StartPoint', [a_guess, b_guess]);

% Unpack curve fit parameters
params = coeffvalues(f1);

% Compute the confidence interval for the fit parameters
uParams = confint(f1, 0.95);

% Compute and plot the fit
if doPlot
    figure;
    x_ = linspace(min(x_data), max(x_data), 100);
    yfit = f1(x_);
    plot(x_data, y_data, 'ro', 'DisplayName', 'Data'); hold on;
    plot(x_, yfit, 'b--', 'DisplayName', 'Model fit', 'LineWidth', 3);
    legend('Location', 'best');
    xlabel('Cocoa content');
    ylabel('Mean break force (N)');
    improvePlot;
end

% Compile fit results for printing
fit_results={};
fit_results(1) = {['Model: ', formula(ft1)]};
fit_results(end + 1) = {" "};
fit_results(end + 1) = {'Params'};
fit_results(end + 1) = {'Mean +/- uncertainty'};
coeff_names = coeffnames(f1);
for i=1:length(coeff_names)
    coeff_name = coeff_names{i};
    out_str = sprintf('%s: %.4e +/- %.4e', coeff_name, params(i), 0.5*(uParams(2,i)-uParams(1,i)));
    fit_results(length(fit_results) +1) = {out_str};
end
       
for i=1:length(fit_results)
    fprintf(strrep(fit_results{i},'%','%%'));
    fprintf('\n');
end

return