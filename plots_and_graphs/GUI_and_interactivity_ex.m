close all;
clear all;

% Make some data to play with
x = 0:0.1:10.0; x=x(:);

% Start with noise
y =  0.5*randn(length(x),1) ;

% Some piecewise linear lines
region1 = x>=2 & x <=6;
y(region1) = y(region1) + 6.*x(region1) -10.;

region2 = x>6;
y(region2) = y(region2)+ 1.*x(region2) + 20.;

% Plot the data
h = figure;
set(h, 'Visible', 'off'); % Hide it so the GUI text input prompt is visible
plot(x, y, 'b.');
improvePlot;

% A loop to ask for text input from the user
ask = 1;
while(ask)
    % Prompt the user for the filename
    filename_out = input('Enter the output filename and press return:  ', 's');
    
    % Prompt the user for the type of analysis
    response = input(['Select example and press return.\n', ...
                      '    p for points\n', ...
                      '    g for polygon\n', ...
                      '    i for lines\n', ...
                      '\n', ...
                      '    q to quit\n'],'s');

    ask = 0;
    switch response
        case 'q'
            disp('Quitting...');
            return
            
        case 'g'
            set(h, 'Visible', 'On');  % Show the plot
            [xs_in_poly, ys_in_poly] = select_points_with_polygon(x, y);
            
        case 'p'
            set(h, 'Visible', 'On'); % Show the plot
            N=2;
            [xs, ys] = select_N_points(N);

        case 'i'
            set(h, 'Visible', 'On'); % Show the plot
            lineCoords = draw_line();
            
            % xs in col 1, ys in col 2
            delta_x = diff(lineCoords(:,1));
            delta_y = diff(lineCoords(:,2));
            line_length = sqrt(delta_x^2 + delta_y^2);
            fprintf('Line is %.2f units long\n', line_length);
            
        otherwise
            ask = 1;
            fprintf('\nInvalid response. Please try again.\n');
    end
        

end

% Save the figure
filename_out = [filename_out, '_', response, '_example']; % append the type of demo example to the filename
print(h, filename_out, '-dpng');