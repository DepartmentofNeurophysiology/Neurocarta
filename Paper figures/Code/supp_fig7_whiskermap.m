function [map, cm] = supp_fig7_whiskermap(folder, save)
%% Supplemental Figure 8: Connectivity in whisker sensorimotor system
% Subplots/information:
% - Connectivity matrix of sensorimotor map
% - (not in Matlab) network cartoon figure

%% Load and match data
if nargin == 0
    folder = 'All';
end

load('whisker_nodes', 'nodelist', 'acros_figure');
all = load(fullfile(folder, 'data.mat'), 'nodelist', 'map');

[a, b] = ismember(nodelist, all.nodelist);
ix = find(contains(nodelist, 'Superior colliculus'));
map = all.map.density(b(a), b(a));
map = [map(1:(ix(1)-1), :) ; mean(map(ix, :)) ; map((ix(2)+1):end, :)];
map = [map(:, 1:(ix(1)-1)) mean(map(:, ix), 2) map(:, (ix(2)+1):end)];
map(1:size(map, 1)+1:end) = 0;
map = min(7 * map / (max(max(map))), 0.7); % Grayscale normalized w.r.t max and limits {0, 0.1}

f = get_save_figure();

%% Imagesc subplot with connectivity matrix
imagesc(cat(3, map, map, map)); axis square;
xlabel('Target'); ylabel('Source');
title('Connectivity map of the whisker system');
set(gca, 'xtick', 1:18, 'xticklabels', acros_figure, 'ytick', 1:18, 'yticklabels', acros_figure, ...
    'xticklabelrotation', -90);
%cm = colormap(gca, 'gray');
%cm = cm(1:size(cm,1)/2, :);
cm = repmat([0:0.01:0.7]', 1, 3);
colormap(gca, cm);
cb = colorbar('eastoutside');
set(get(cb, 'Label'), 'String', 'Projection density', 'FontSize', 9);
caxis([0 0.1]);

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end