function f = get_save_figure(f, folder, fname)

% Create new figure
if nargin == 0
    %f = figure('WindowState', 'maximized', 'PaperUnits', 'normalized', 'PaperOrientation', 'landscape', ...
    %    'PaperPositionMode', 'manual', 'PaperPosition', [0 0 1 1]);
    f = figure('WindowState', 'maximized');
elseif nargin == 3
    saveas(f, fullfile(folder, fname), 'fig');
    saveas(f, fullfile(folder, fname), 'pdf');
    saveas(f, fullfile(folder, fname), 'svg');
    close(f);
end