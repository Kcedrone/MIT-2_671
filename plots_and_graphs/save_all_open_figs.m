function [] = save_all_open_figs(fig_prefix)
if nargin < 1
    if exist('fig_prefix', 'var')
        output_str_fmt = [fig_prefix '_fig_%d'];
    else
        output_str_fmt = 'fig_%d';
    end
elseif nargin == 1
    output_str_fmt = [fig_prefix '_%d'];
else
    fprintf(2, 'Error: too many input arguments.');
    return
end

% Find all open figures
figHandles = findall(groot, 'Type', 'figure'); 
% Iterate through all open figures
for i = 1:length(figHandles)
    % For this figure handle
    fH = figHandles(i);
    
    % Get the figure number
    num = get(fH, 'Number');

    % Make a filename using the format and figure number
    filename_out = sprintf(output_str_fmt, num); 

    % Save the figure as a PNG
    print(fH, filename_out, '-dpng');
end
