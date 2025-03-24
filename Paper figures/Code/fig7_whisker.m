function [map, col, cm1, cm2] = fig7_whisker(folder, save)
%% Figure 7: Sex difference in whisker sensorimotor system
% Subplots/information:
% - Connectivity matrix of sensorimotor map
% - (not in Matlab) network cartoon figure

% load nodelist or acros or something
% match with diff/data.mat maps
% fix SCs, SCm (11 resp. 12) by averaging

%% Load and match data
if nargin == 0
    folder = 'All';
end

load('whisker_nodes', 'nodelist', 'acros_figure');
all = load(fullfile(folder, 'data.mat'), 'nodelist', 'map');
mf = load('diff/data.mat', 'nodelist', 'm1', 'm2');

[a, b] = ismember(nodelist, all.nodelist);
ix = find(contains(nodelist, 'Superior colliculus'));
map = all.map.density(b(a), b(a));
map = [map(1:(ix(1)-1), :) ; mean(map(ix, :)) ; map((ix(2)+1):end, :)];
map = [map(:, 1:(ix(1)-1)) mean(map(:, ix), 2) map(:, (ix(2)+1):end)];

m1 = zeros(length(nodelist));
m2 = zeros(length(nodelist));
[a, b] = ismember(nodelist, mf.nodelist);
ix = find(contains(nodelist, 'Superior colliculus'));
m1(a, a) = mf.m1.density(b(a), b(a));
m2(a, a) = mf.m2.density(b(a), b(a));
m1 = [m1(1:(ix(1)-1), :) ; mean(m1(ix, :)) ; m1((ix(2)+1):end, :)];
m1 = [m1(:, 1:(ix(1)-1)) mean(m1(:, ix), 2) m1(:, (ix(2)+1):end)];
m2 = [m2(1:(ix(1)-1), :) ; mean(m2(ix, :)) ; m2((ix(2)+1):end, :)];
m2 = [m2(:, 1:(ix(1)-1)) mean(m2(:, ix), 2) m2(:, (ix(2)+1):end)];

col = ((m1 > m2) - 0.5) * 2; % convert from {0,1} to {-1,1}
a(ix(1)) = [];
col(~a, :) = 0;
col(:, ~a) = 0;
col(1:size(col, 1)+1:end) = 0;

m3 = abs((m1-m2) ./ (m1+m2));
map(col ~= 0) = m3(col ~= 0);
map(1:size(map, 1)+1:end) = 0;

r = zeros(length(nodelist)-1);
r(col == 0) = min(7 * map(col == 0) / (max(max(map(col==0)))), 0.7); g = r; b = r; % Grayscale normalized w.r.t max and limits {0, 0.1}
r(col == -1) = 1;
r(col == 1) = 1 - map(col == 1);
g(col ~= 0) = 1 - abs(map(col ~= 0));
b(col == -1) = 1 - map(col == -1);
b(col == 1) = 1;

f = get_save_figure();

%% Imagesc subplot with connectivity matrix
subplot(1, 8, [2 3 4 5 6 7]);
%{
subplot(1,2,1);
imagesc(map); colormap(gca, cm(27:end, :)); caxis([0 1]); colorbar('eastoutside'); axis square;
set(gca, 'xtick', 1:18, 'xticklabels', acros_figure, 'ytick', 1:18, 'yticklabels', acros_figure)
subplot(1,2,2);
imagesc(col); colormap(gca, cm); colorbar('eastoutside'); axis square;
set(gca, 'xtick', 1:18, 'xticklabels', acros_figure, 'ytick', 1:18, 'yticklabels', acros_figure)
%}

imagesc(cat(3, r, g, b)); axis square;
xlabel('Target'); ylabel('Source');
title('Sex-comparative map of the whisker system');
set(gca, 'xtick', 1:18, 'xticklabels', acros_figure, 'ytick', 1:18, 'yticklabels', acros_figure);

%% Colorbar left red-blue
subplot(1, 8, 1);
set(gca, 'Visible', 'off');
cm1 = [[ones(26,1) linspace(0,1,26)' linspace(0,1,26)'];[linspace(1,0,26)' linspace(1,0,26)' ones(26,1)]];
colormap(gca, cm1);
cb = colorbar('east');
set(get(cb, 'Label'), 'String', 'Comparative projection density', 'FontSize', 12);
caxis([-1 1]);

%% Colorbar right grayscale
subplot(1, 8, 8);
set(gca, 'Visible', 'off');
%cm2 = colormap(gca, 'gray');
%cm2 = cm2(1:size(cm2,1)/2, :);
cm2 = repmat([0:0.01:0.7]', 1, 3);
colormap(gca, cm2);
cb = colorbar('west');
set(get(cb, 'Label'), 'String', 'Projection density', 'FontSize', 12);
caxis([0 0.1]);

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end