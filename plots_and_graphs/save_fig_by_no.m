function [] = save_fig_by_no(fig_prefix)
if nargin < 1
    if exist('fig_prefix', 'var')
        output_str_fmt = fig_prefix;
    else
        output_str_fmt = datestr(now);
    end
elseif nargin == 1
    output_str_fmt = fig_prefix;
else
    fprintf(2, 'Error: too many input arguments.');
    return
end

figHandles = findall(groot, 'Type', 'figure'); % Find all open figures
for i = 1:length(figHandles)
    fH = figHandles(i);
    fig_no = fH.Number;

    filename_out = sprintf([output_str_fmt '_fig_no_%02d'], fig_no); % Make a file name with figure number
    outpath = filename_out;
    print(fH, outpath, '-dpng'); % Save figure as png
end
