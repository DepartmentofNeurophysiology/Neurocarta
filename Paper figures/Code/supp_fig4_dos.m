function supp_fig4_dos(folder, save)
%% Supplemental figure 4: DOS for unfiltered maps (left side)

%% Load and normalize
if nargin == 0
    folder = 'All';
end

load(fullfile(folder, 'data'), 'dos', 'mode');
f = get_save_figure();

mindos = 0;
maxdos = 0;
for m = 1:3
    % Calculate maximum DOS in the 3 displayed matrices, for caxis
    d = dos.(mode{m}){1};
    mindos = min(mindos, min(d(~isinf(d))));
    maxdos = max(maxdos, max(d(~isinf(d))));
end
cm = get_cmap([mindos maxdos], true);

%% DOS maps per mode and threshold
for m = 1:3
    subplot(3, 1, m);
    imagesc(dos.(mode{m}){1}); axis equal tight; colormap(gca, cm.cm);
    set(gca, 'XTick', [], 'YTick', []);
    caxis(cm.lims);
    colorbar('eastoutside', 'TickLength', 0, 'Ticks', cm.ticks, ...
        'TickLabels', cm.ticklabels);
    title(mode{m});
    xlabel('ipsilateral \leftarrow Targets \rightarrow contralateral');
    ylabel('Sources');
end

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end