[file, path] = uigetfile('*.xlsx','Select Excel file');

% Convert file info to full path
ff = fullfile(path, file);

% Read information about the Excel file
[status, sheets] = xlsfinfo(ff);

% Convert row-cell list of sheets to a column cell list of sheets
sheets = sheets(:);
N_sheets = length(sheets);

% Pre-allocate variables
% Each entry will be a vector that has values for each individual test
% The vectors will be grouped on a per-sheet basis
peak_forces_by_sheet = cell(N_sheets, 1);

% Iterate over all of the sheets in the Excel file
for sheet_idx = 1:N_sheets
    this_sheet = sheets{sheet_idx};
    % Read the sheet
    [num, txt, raw] = xlsread(ff, this_sheet);
    
    % Find the number of data columns in the sheet
    N_columns = size(num, 2);
    
    % The texture analyzer usually gives force, distance and time columns for each test
    % So the total number of columns should be evenly divisible by 3.
    if mod(N_columns, 3)
        fprintf(2,'Error: number of columns not a multiple of 3!\n');
        return
    end
    N_tests = N_columns/3;
    
    % Pre-allocate variable, one for each test
    peak_force = zeros(N_tests, 1);
    
    % Iterate over all of the tests in the sheet
    for test_idx = 1:N_tests
        col_offset = 3*(test_idx-1);
        
        % This part expects that the columns be in a consistent order
        force = num(:, col_offset + 1);
        dist = num(:, col_offset + 2);
        time = num(:, col_offset + 3);

        % Find the maximum value of the force, and the index of the array
        % where the maximum value occurs
        [max_force_val, idx_max_force_val] = max(force);
        
        % Store the peak value of this test
        peak_force(test_idx) = max_force_val;
        
        % Create a mask to select data from the start of the file up to the
        % peak of the force
        up_to_max = 1:idx_max_force_val;

        % Fit a line to some portion of the force data
        % In this case, the force data when force is:
        % Greater than 10% of the peak force and less than 90% of the peak force
        start_thresh = 0.1;
        end_thresh = 0.9;
        
        idx_fit_start = find(force > start_thresh*max_force_val, 1, 'first');
        idx_fit_end = find(force > end_thresh*max_force_val, 1, 'first');
        
        fit_range = idx_fit_start:idx_fit_end;
        
        [f1, params, uParams, fit_is_significant] = linear_fit(dist(fit_range), force(fit_range), 0);
        
  
    end

    
peak_forces_by_sheet{sheet_idx} = peak_force;


    
end

% Add sheet names to the sheet-organized data
data_for_analysis = [sheets, peak_forces_by_sheet];

%% Compute uncertainty of mean values
conf = 0.95;

mean_val = zeros(N_sheets, 1);
unc_val = zeros(N_sheets, 1);
for i = 1:N_sheets
    peak_force_vals = peak_forces_by_sheet{i};
    N_vals = length(peak_force_vals);
    mean_val(i) = mean(peak_force_vals);
    dof = N_vals - 1;
    tfactor = tinv( 1-(1-conf)/2., dof);
    unc_val(i) = tfactor*std(peak_force_vals)/sqrt(N_vals);
end

% Plot mean values with error bars based on category
c = categorical(sheets);
figure;
hold on;
plot(c, mean_val, 'ko')
% Add error bars
eh = errorbar(c, mean_val, unc_val);
eh.LineStyle='none';
ylabel('Peak Force (N)');
improvePlot;
% Move the error bars to the back, and points to the front
chi=get(gca, 'Children');
set(gca, 'Children',flipud(chi));

