function supp_fig5_weighted_dos(folder, save)
%% Supplemental figure 6: Weigted DOS: # of synapses along shortest path
% Bilateral synapse matrices
% Distribution for synapses, ipsi/contra
% Per region

%% Load
if nargin == 0
    folder = 'All';
end

load('structures', 'structures', 'regions');
load(fullfile(folder, 'data'), 'dist', 'pathdos', 'ids');
N = size(pathdos.density, 1);
ipsi = pathdos.density(:, 1:N);
contra = pathdos.density(:, N+1:end);
dist = dist.density;
clear pathdos;

[~, index] = ismember(ids, structures.id);
node_regs = structures.region(index);
node_acros = structures.acro(index);
NR = length(regions.name);

ipsi_input = sum(ipsi);
contra_input = sum(contra);
ipsi_output = sum(ipsi, 2)';
contra_output = sum(contra, 2)';

f = get_save_figure();

%% Bilateral pathlength maps
subplot(10, 10, [1:4 11:14 21:24 31:34 41:44]);
cm = get_cmap([ipsi contra], true);
imagesc([ipsi contra]); axis equal tight; colormap(gca, cm.cm); caxis(cm.lims);
cb = colorbar('southoutside', 'TickLength', 0, 'Ticks', cm.ticks, ...
    'TickLabels', cm.ticklabels);
ylabel(cb, 'Weighted DOS');
%cb = colorbar('southoutside'); ylabel(cb, 'Weighted DOS');
set(gca, 'XTick', [], 'YTick', []);
xlabel('ipsilateral  \leftarrow  Targets  \rightarrow  contralateral');
ylabel('Sources');
title('Weighted DOS: number of edges along shortest path');

%% Incoming distance per node
h = subplot(10, 10, 51:53);
lineplot_subplot(h, ipsi_input, contra_input, true);
ylabel('Weighted DOS'); title('Total weighted DOS from source nodes');

%% Outgoing distance per node
h = subplot(10, 10, [5 15 25 35]);
lineplot_subplot(h, ipsi_output, contra_output, false);
ylabel('Weighted DOS');

%% Average density per region
subplot(10, 10, [7:10 17:20 27:30 37:40]);
avgi = zeros(NR);
avgc = zeros(NR);
for i = 1:NR
    for j = 1:NR
        avgi(i,j) = mean(mean(ipsi(node_regs==i, node_regs==j)));
        avgc(i,j) = mean(mean(contra(node_regs==i, node_regs==j)));
    end
end
cm = get_cmap([avgi avgc]);
imagesc([avgi avgc]); axis equal tight; colormap(gca, cm.cm); caxis(cm.lims);
set(gca, 'ticklength', [0 0], 'xtick', 1:2*NR, 'ytick', 1:NR, ...
    'xticklabels', [regions.acro regions.acro], 'yticklabels', [regions.acro]);
xlabel('ipsilateral \leftarrow Postsynaptic targets \rightarrow contralateral');
ylabel('Presynaptic sources');
title('Average weighted DOS between regions');
cb = colorbar('eastoutside'); ylabel(cb, 'Weighted DOS');

%% Weighted DOS vs path distance boxplot
subplot(10, 10, [61:64 71:74 81:84 91:94]);
tmp = [ipsi contra];
ix = find(tmp>0 & dist<inf);
boxplot(dist(ix), tmp(ix), 'Orientation', 'horizontal', 'BoxStyle', 'outline', ...
    'Colors', 0.5*[1 1 1], 'Symbol', 'x');
ch = get(get(gca, 'Children'), 'Children');
boxes = ch(strcmp(get(ch, 'Tag'), 'Box'));
set(boxes, 'LineWidth', 1);
set(gca, 'Color', 'none');
xlabel('Shortest path length');
ylabel('Weighted DOS');
title('Weighted DOS vs path length');

%% Weighted DOS vs euclidean distance boxplot
subplot(10, 10, [67:70 77:80 87:90 97:100]);
eu = load('euclidean', 'map', 'ids');
[a, b] = ismember(eu.ids, ids);
ids = ids(b(a));
ipsi = ipsi(b(a), b(a));
contra = contra(b(a), b(a));
eu = rmfield(eu, 'ids');
eu.map = eu.map(a, [a a]);

tmp = [ipsi contra];
ix = find(tmp>0 & dist<inf);
boxplot(eu.map(ix), tmp(ix), 'Orientation', 'horizontal', 'BoxStyle', 'outline', ...
    'Colors', 0.5*[1 1 1], 'Symbol', 'x');
ch = get(get(gca, 'Children'), 'Children');
boxes = ch(strcmp(get(ch, 'Tag'), 'Box'));
set(boxes, 'LineWidth', 1);
set(gca, 'Color', 'none');
xlabel('Euclidean distance');
ylabel('Weighted DOS');
title('Weighted DOS vs euclidean distance');

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end