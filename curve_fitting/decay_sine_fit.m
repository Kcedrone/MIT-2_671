function [f1, params, uParams, fit_is_significant] = decay_sine_fit(x, y, doPlots)
% If the function is run with no inputs, invent some demo data
if nargin == 0
    x = 1:0.1:20;
    y = 2*exp(-0.1*x).*sin(3*x + 4) + 0.1*randn(size(x));
    doPlots = 1;
end

% Make x and y inputs into columns
x=x(:);
y=y(:);

% Define the functional form of the fit
ft1 = fittype('a*exp(-b*x).*sin(c*x+d)+e');

% The key to a good fit is good starting guesses
% When I don't know what the coefficients will be, I guess, run the fit
% once then run it again using the output of the first iteration and some 
% engineering judgment to select starting points for the second iteration.
a_guess = (max(y)-min(y))/2.0;  % Reasonable guess for amplitude
b_guess = 0.1;                  % Decaying sine should be damped, |b| < 1
% Could estimate frequency c from PSD or FFT...
c_guess = 5;                   % Code seems to work better starting from high values
d_guess = 0;                    % Has to be 0 to 2*pi
e_guess = mean(y);              % Good guess for the offset

% You can also specify lower and upper bounds on each parameter. This is
% especially helpful if a term or grouping of terms would make no physical 
% sense as a negative (e.g. negative time, negative amplitude, etc.), or
% for periodic functions.
% There are many other advanced options (e.g. Least Absolute Residuals,
% Bisquare, etc.) and outputs (e.g. different measures of goodness of fit)
% See MATLAB documentation for details

f1 = fit(x, y, ft1, 'StartPoint', [a_guess, b_guess, c_guess, d_guess, e_guess], ...
                     'Lower', [0, 0, 0, 0, -Inf], ...
                     'Upper', [Inf, Inf, Inf, 2*pi, Inf]); 

% Unpack curve fit parameters
params = coeffvalues(f1);

% Compute the confidence interval for the fit parameters
param_CI = confint(f1, 0.95);
uParams = 0.5*diff(param_CI);

% Compile fit results for printing
fit_results={};
fit_results(1) = {['Model: ', formula(ft1)]};
fit_results(end + 1) = {" "};
fit_results(end + 1) = {'Params'};
fit_results(end + 1) = {'Mean +/- uncertainty'};
coeff_names = coeffnames(f1);
fit_is_significant = true;
for i=1:length(coeff_names)
    coeff_name = coeff_names{i};
    param = params(i);
    %     uParam = 0.5*(uParams(2,i)-uParams(1,i));
    uParam = uParams(i);
    out_str = sprintf('%s: %.4e +/- %.4e', coeff_name, param, uParam);
    if abs(uParam) >= abs(param)
        out_str = strcat(out_str, ' (Warning: parameter not significant)');
        fit_is_significant = false;
    end
    fit_results(length(fit_results) +1) = {out_str};
end

% Plot the fit
if doPlots
    
    % Plot data with fit
    if fit_is_significant
        fit_line_style = 'b-';
    else
        fit_line_style = 'b--';
    end
    
    figure;
    x_ = linspace(min(x), max(x), 100);
    yfit = f1(x_);
    plot(x, y, 'ro', 'DisplayName', 'Data'); hold on;
    plot(x_, yfit, fit_line_style, 'DisplayName', 'Model fit', 'LineWidth', 3);
    improvePlot();
    
    %     % Print fit results on the plot
    %     annotation( 'textbox', [0.15 0.25 0.5 0.5], ...
    %             'FitBoxToText','on', ...
    %             'String', fit_results, ...
    %             'FontSize',18, ...
    %             'Color',[0 0 0], ...
    %             'LineStyle','-', ...
    %             'EdgeColor',[0 0 0], ...
    %             'LineWidth',2, ...
    %             'BackgroundColor',[0.9  0.9 0.9], ...
    %             'FaceAlpha', 0.5);
    
    % Plot residuals
    h = plot_residuals(x, y, f1);
    
end

for i=1:length(fit_results)
    fprintf(fit_results{i});
    fprintf('\n');
end

    function [h] = plot_residuals(x, y, fit_fcn)
        x = x(:);
        y = y(:);
        
        
        observed = y;
        predicted = fit_fcn(x);
        residual = observed - predicted;

        % If there are more than 30 data points, we can fit a histogram to
        % the residuals and see how well they approximate a normal
        % distribution.
        N_pts = length(x);
        
        h = figure;
        if N_pts >= 30
        subplot(2,1,1);
        end
        plot(x, residual, 'bo');
        hold on;
        
        title('Residual plot');
        xlabel('X value');
        ylabel('Residual (data - fit)');
        improvePlot;
        ax = gca;
        xL = xlim;
        line(xL, [0 0],'color','k', 'linewidth', ax.LineWidth) %x-axis
        
        % Plot histogram of residuals
        if N_pts >= 30
        N_bins = 20;
        
        subplot(2,1,2);
        %     h = histogram(residual, N_bins, 'Normalization', 'pdf', 'DisplayStyle', 'Stairs', 'LineWidth', 2, 'DisplayName', 'Histogram');
        h = histogram(residual, N_bins, 'Normalization', 'pdf', 'DisplayName', 'Histogram', 'LineWidth', 3);
        hold on;
        xlabel('Residual value');
        ylabel('Probability');
        h.EdgeColor = 'white';
        h.FaceAlpha = 0.5;
        bin_edges = h.BinEdges;
        
        % Fit data to a Guassian model (i.e. normal PDF)
        sd = std(residual);
        mu = mean(residual);
        x = linspace(min(bin_edges), max(bin_edges), 100);
        g = normpdf(x, mu, sd);
        plot(x, g, '-', 'LineWidth', h.LineWidth, 'Color', 'k', 'DisplayName', 'Norm. distr');
        legend('show');
        
        improvePlot;
        ax = gca;
        yL = ylim;
        line([0 0], yL, 'color', 'k', 'linewidth', ax.LineWidth, 'HandleVisibility', 'off'); % y-axis
        end
        
    end

end