%% Code to select an input data files, and iterate over them
clc;
clearvars;
close all;

FILE_EXT = 'csv'; % Select your file extension (e.g. csv, txt, wav, etc.)
[filename, data_file_path, success] = uigetfile(['*.',FILE_EXT], 'Select input file');

if ~success
    fprintf('Error: No files selected...\n');
    return
end

%% Load experimental data
full_file = fullfile(data_file_path, filename);
[filenames, measurement, units, data] = load_CSV_file_custom(filename);

%%
N_COLS_PER_TEST = 3; % Each test created 3 columns, Force, distance and time.
N_cols = length(filenames);
N_tests = N_cols/N_COLS_PER_TEST;

% Pre-allocate arrays to collect values from each loop iteration
list_of_colors = cell(N_tests, 1);
strain_rate = zeros(N_tests, 1);
run_numbers = zeros(N_tests, 1);

Max_Break_Force_array = zeros(N_tests, 1);

force_dist_slope_array = zeros(N_tests, 2); % First col is val, second col is uncertainty
force_dist_offset_array = zeros(N_tests, 2); % First col is val, second col is uncertainty


for ii = 1:N_tests % Loop over each file
    starting_col_index = N_COLS_PER_TEST*(ii-1)+1;
    
    this_file_name = filenames{starting_col_index};
    
    % Parse file name
    space_split = strsplit(this_file_name, ' ');
    list_of_colors{ii} = space_split{1};
    
    date = space_split{2}; % For clarity
    
    strain_rate_code = space_split{3};
    if contains(strain_rate_code, '-')
        strain_rate_dash_split = strsplit(strain_rate_code, '-');
        strain_rate(ii) = str2double(strain_rate_dash_split{1}) + 0.1*str2double(strain_rate_dash_split{2});
    else
        strain_rate(ii) = str2double(strain_rate_code);
    end
    
    run_num = space_split{4};
    run_numbers(ii) = str2double(run_num);

    % Assign variables for this test
    for h = 0:(N_COLS_PER_TEST - 1)
        col_index = starting_col_index + h;
        if contains(measurement{col_index}, 'force', 'IgnoreCase', true)
            force__N = 0.001*9.81*data(:, col_index); % Convert from g to kg to N
        elseif contains(measurement{col_index}, 'distance', 'IgnoreCase', true)
            dist__mm = data(:, col_index);
        elseif contains(measurement{col_index}, 'time', 'IgnoreCase', true)
            time__s = data(:, col_index);
        else
            fprintf('Error in col assignment.\n');
            return
        end
    end
    
    % DO SOMETHING ON THE RUN THAT WAS JUST LOADED
    % Find max force
    [max_force__N, idx_max] = max(force__N);

    % A sample level 1 plot for 3rd test
    if ii == 3
        figure;
        plot(dist__mm, force__N, 'b.'); hold on;
        xlabel('Distance (mm)');
        ylabel('Force (N)');
        title(this_file_name);
        improvePlot;
    end
    
    % Create a mask to find when force is increasing 
    % Might need to adjust thresholds or add conditions here
    dForce = [0; diff(force__N)];
    rising_force = (dForce > 0.0);
    
    % Extract just the portion of distance and force where rising_force 
    % (defined above) is true
    xdata = dist__mm(rising_force);
    ydata = force__N(rising_force);
    
    [params, uParams] = lin_fit(xdata, ydata, 0);
    
    % Save variables from this loop iteration
    Max_Break_Force_array(ii) = max_force__N;
    force_dist_slope_array(ii, 1:2) = [params(1) diff(uParams(1))];
    force_dist_offset_array(ii, 1:2) = [params(2) diff(uParams(2))];
    
end

%%
% Save a results file for later analysis
% There are simpler ways to save output on Windows such as XLSWrite but for
% some reason XLSWrite doesn't work on Mac in the year 2018...
output_file = 'results.csv';
filenames_of_each_test = filenames(1:N_COLS_PER_TEST:end);
header_row = [{'Result (units)/Filename'}, filenames_of_each_test];
row_headings = {'Max break force (N)', 'Force-dist slope (N/mm)', 'Unc. of force-dist slope (N/mm)'};
rows = {Max_Break_Force_array, force_dist_slope_array(:,1), force_dist_slope_array(:, 2)};

% Open a file
fid = fopen(output_file, 'w');
% Save the header row at the top of the file
fprintf(fid, '%s,', header_row{1,1:end-1}) ;
fprintf(fid, '%s\n', header_row{1,end}) ;

for i =1:length(rows)
 % Save the row heading
    fprintf(fid, '%s,', row_headings{1,i});
% Save the values corresponding to that row
    vals = rows{i};
    fprintf(fid, '%.8f,', vals(1:end-1)) ;
    fprintf(fid, '%.8f\n', vals(end)) ;
end
% Close the file
fclose(fid);

%% Alternatively, you could save results to a .MAT for later MATLAB analysis
MAT_output_file = 'results.MAT';
filenames_of_each_test = filenames(1:N_COLS_PER_TEST:end);
%MATLAB wants the names of variables as strings
save(MAT_output_file, 'list_of_colors', 'filenames_of_each_test','Max_Break_Force_array', 'force_dist_slope_array');


%% 
% Load from MAT file
clearvars;
load('results.MAT')

% Level 2
figure;
plot(Max_Break_Force_array, 'ko');
xlabel('Run no.');
ylabel('Max force (N)');
improvePlot;


%% Example of how to search for a property then plot based on it
shapes = {'o', 's', '^', 'd', 'v', 'x', '+'}; % List of markers for plot
colors = {'k', 'r', 'b', 'g', 'c', 'm', 'y'}; % List of colors for plot
figure; 
hold on;

colors_to_search = {'AQUA', 'WHITE'};
for jj = 1:length(colors_to_search)
    this_color = colors_to_search{jj};
    indices = find(contains(list_of_colors, this_color, 'ignorecase', true));
    
    if ~isempty(indices)    
        % Compute mean and uncertainty of mean
        [mean_Max_Force, uMean95] = uncertainty(Max_Break_Force_array(indices), 0.95);
        
        marker_style = [colors{jj} shapes{jj}];
        eh = errorbar(jj, mean_Max_Force, uMean95, marker_style);
        xlabel('Run no.'); 
        ylabel('Mean Break Force (N)');
        improvePlot;
    end
end
