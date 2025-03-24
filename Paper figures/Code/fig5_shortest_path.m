function fig5_shortest_path(folder, save)
%% Figure 5: Shortest path pathlength
% Bilateral dist matrices
% Total in/output per node for ipsi/contra hemispheres
% Ratio between input/output per node
% Average projection density between brain regions and hemispheres

%% Load
if nargin == 0
    folder = 'All';
end

load('structures', 'structures', 'regions');
load(fullfile(folder, 'data'), 'dist', 'ct', 'ids');

% Exclude Node no. 266 which is a strange outlier due to only having 1
% non-zero outgoing projection density value.
if strcmp(folder, 'All')
    N = size(dist.density, 1);
    dist.density(:, [265+N 266+N]) = [];
    dist.density(:, [265 266]) = [];
    dist.density([265 266], :) = [];
    %dist.density(:, 266+N) = [];
    %dist.density(:, 266) = [];
    %dist.density(266, :) = [];
    ct.density([265+N 266+N]) = [];
    ct.density([265 266]) = [];
    %ct.density(266+N) = [];
    %ct.density(266) = [];
    ids([265 266]) = [];
    %ids(266) = [];
end

N = size(dist.density, 1);
ipsi = dist.density(:, 1:N);
contra = dist.density(:, N+1:end);
clear dist;
ct = ct.density;

[~, index] = ismember(ids, structures.id);
node_regs = structures.region(index);
node_acros = structures.acro(index);
NR = length(regions.name);

ipsi_input = mean(ipsi);
contra_input = mean(contra);
ipsi_output = mean(ipsi, 2)';
contra_output = mean(contra, 2)';

f = get_save_figure();

%% Bilateral pathlength maps
subplot(10, 10, [1:4 11:14 21:24 31:34 41:44]);
cm = get_cmap([ipsi contra]);
imagesc([ipsi contra]); axis equal tight; colormap(gca, cm.cm); caxis(cm.lims);
cb = colorbar('southoutside'); ylabel(cb, 'Weighted Distance');
set(gca, 'XTick', [], 'YTick', []);
xlabel('ipsilateral  \leftarrow  Targets  \rightarrow  contralateral');
ylabel('Sources');
title('Shortest paths between nodes');

%% Incoming distance per node
h = subplot(10, 10, 51:53);
lineplot_subplot(h, ipsi_input, contra_input, true);
ylabel('Weighted Distance'); title('Average weighted distance from source nodes');

%% Outgoing distance per node
h = subplot(10, 10, [5 15 25 35 45]);
lineplot_subplot(h, ipsi_output, contra_output, false);
ylabel('Weighted Distance');

%% Average distance per region matrix
subplot(11, 10, [7:10 17:20 27:30]);
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
xlabel('ipsilateral \leftarrow Targets \rightarrow contralateral');
ylabel('Sources');
title('Average weighted distance per region');
cb = colorbar('eastoutside'); ylabel(cb, 'Average weighted distance');

%% Average distance per region boxplot
subplot(11, 10, [47:50 57:60 67:70]);
data = [];
grp = [];
for i = 1:NR
    tmp = mean([ipsi(node_regs==i, node_regs~=i) contra(node_regs==i, node_regs~=i) ; ...
        ipsi(node_regs~=i, node_regs==i)'  contra(node_regs~=i, node_regs==i)']);
        %ipsi(node_regs~=i, node_regs==i)']);
    data = [data tmp];
    grp = [grp i*ones(1, length(tmp(:)))];
end

boxplot(data, grp, 'BoxStyle', 'outline', 'Colors', regions.color*0.75, 'Symbol', 'x');

% Mark outliers with node labels
ch = get(get(gca, 'Children'), 'Children');
boxes = ch(strcmp(get(ch, 'Tag'), 'Box'));
set(boxes, 'LineWidth', 1);
outliers = ch(strcmp(get(ch, 'Tag'), 'Outliers'));
for i = 1:NR
    acros_tmp = [node_acros(node_regs~=i) strcat('c', node_acros(node_regs~=i))];
    grp_tmp = [node_regs(node_regs~=i) node_regs(node_regs~=i)];
    xdata = get(outliers(i), 'XData');
    if isnan(xdata)
        continue
    end
    ydata = get(outliers(i), 'YData');
    for j = 1:length(xdata)
        ix = grp==xdata(j);
        text(xdata(j)+0.1, ydata(j), acros_tmp(data(ix)==ydata(j)), 'FontSize', 6);
    end
end

set(gca, 'Color', 'None', 'XTickLabels', regions.acro);
xlabel('Brain regions');
ylabel('Average pathlength');
title('Average inter-brain region pathlength');

%% Betweenness centrality boxplot
subplot(11, 10, [87:90 97:100 107:110]);
boxplot(ct, [node_regs;node_regs+NR], 'BoxStyle', 'outline', ...
    'Colors', regions.color*0.75, 'Symbol', 'x');

% Mark outliers with node labels
ch = get(get(gca, 'Children'), 'Children');
boxes = ch(strcmp(get(ch, 'Tag'), 'Box'));
set(boxes, 'LineWidth', 1);
outliers = ch(strcmp(get(ch, 'Tag'), 'Outliers'));
acros_tmp = [node_acros node_acros];
grp_tmp = [node_regs node_regs];
for i = 1:2*NR
    xdata = get(outliers(i), 'XData');
    if isnan(xdata)
        continue
    end
    ydata = get(outliers(i), 'YData');
    for j = 1:length(xdata)
        text(xdata(j)+0.1, ydata(j), acros_tmp(ct==ydata(j)), 'FontSize', 6);
    end
end

set(gca, 'Color', 'none', 'XTickLabels', regions.acro);
xlabel('ipsilateral \leftarrow Brain regions \rightarrow contralateral');
ylabel('Betweenness centrality');
title('Betweenness centralities per brain region');

%% Weighted DOS plot
subplot(10, 10, [71:75 81:85 91:95]);
load('wdosdata', 'sf', 'mn', 'mx', 'st');
Nt = length(sf);
hold on;
plot(sf, mn);
fill([sf sf(Nt:-1:1)], [mn-st mn(Nt:-1:1)+st(Nt:-1:1)], 'blue', ...
    'FaceAlpha', 0.3, 'EdgeColor', 'none');
plot(sf, mx);

set(gca, 'Color', 'none');
xlim([1 max(sf)]);
ylim([0 max(mx)+1]);
xlabel('Synapse factor');
ylabel('Weighted DOS');
title('Average weighted DOS (#synapses along shortest path) as a function of synapse factor');
legend('Mean', 'Std', 'Max');

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end