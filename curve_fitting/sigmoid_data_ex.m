%% Invent some s-shaped data
x = 50:5:250;

y0 = 120;
delta_y = -20.0;
k = 0.2;
x0 = 190.5;

y = y0 + delta_y./(1 + exp(-k*(x-x0)));

y = y + 2.0*randn(size(x));

%% Fit the S-shaped data!

[params, uParams] = sigmoid_fit(x, y, 1);
xlabel('Heartrate (bpm)');
ylabel('Force (N)');
improvePlot;
% Find and destroy the legend
hL = findobj(gcf, 'Type', 'Legend');
delete(hL);

function [params, uParams] = sigmoid_fit(x, y, doPlots)

% Make sure inputs are columns
x=x(:);
y=y(:);

ft1 = fittype('y0 + delta_y./(1 + exp(-k*(x-x0)))', 'coefficients', {'y0', 'delta_y', 'k', 'x0'});

% The key to a good fit is good starting guesses
y0_guess = mean(y);
delta_y_guess = min(y);
k_guess = 0.1;
mid_val = (min(y) + max(y))/2;
x0_guess = x( find((y > mid_val & circshift(y, -1) <= mid_val), 1, 'first')); % d parameter is at half-way from y0 to y0+delta_y

f1 = fit(x, y, ft1, 'StartPoint', [y0_guess, delta_y_guess, k_guess, x0_guess], ...
                     'Lower', [-2*abs(min(y)), -Inf, 0, min(x)], ...
                     'Upper', [2*abs(max(y)), Inf, Inf, max(x)]); 

% Unpack curve fit parameters
params = coeffvalues(f1);

% Compute the confidence interval for the fit parameters
uParams = confint(f1, 0.95);

% Compute and plot the fit
if doPlots
    figure;
    x_ = linspace(min(x), max(x), 100);
    yfit = f1(x_);
    plot(x, y, 'ro', 'DisplayName', 'Data'); hold on;
    plot(x_, yfit, 'b-', 'DisplayName', 'Model fit', 'LineWidth', 3);
    improvePlot();
    legend('Location','best');
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
    param = params(i);
    uParam = 0.5*(uParams(2,i)-uParams(1,i));
    out_str = sprintf('%s: %.4e +/- %.4e', coeff_name, param, uParam);
    if abs(uParam) >= abs(param)
        out_str = strcat(out_str, ' (Warning: parameter not significant)');
    end
    fit_results(length(fit_results) +1) = {out_str};
end

% Print fit results on the plot
% annotation( 'textbox', [0.15 0.25 0.5 0.5], ...
%             'FitBoxToText','on', ...
%             'String', fit_results, ...
%             'FontSize',18, ...
%             'Color',[0 0 0], ...
%             'LineStyle','-', ...
%             'EdgeColor',[0 0 0], ...
%             'LineWidth',2, ...
%             'BackgroundColor',[0.9  0.9 0.9], ...
%             'FaceAlpha', 0.5);
       
for i=1:length(fit_results)
    fprintf(fit_results{i});
    fprintf('\n');
end


end