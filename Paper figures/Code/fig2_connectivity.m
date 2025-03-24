function fig2_connectivity(folder, save)
%% Figure 2: General connectivity
% Subplots/information:
% - Ipsilateral projections dominate connectivity
% - Total in/output per node for ipsi/contra hemispheres
% - Average projection density between brain regions and hemispheres
% - Projection density vs euclidean distance

%% Load
if nargin == 0
    folder = 'All';
end

load('structures', 'structures', 'regions');
load(fullfile(folder, 'data'), 'map', 'ids');
map = map.density;
N = size(map, 1);
ipsi = map(:, 1:N);
contra = map(:, N+1:end);
clear map;

[~, index] = ismember(ids, structures.id);
node_regs = structures.region(index);
node_acros = structures.acro(index);
NR = length(regions.name);

yt = zeros(NR, 1);
for i = 1:NR
    yt(i) = sum(node_regs == i);
end
yt = cumsum(yt(1:NR-1));

ipsi_input = sum(ipsi);
contra_input = sum(contra);
ipsi_output = sum(ipsi, 2)';
contra_output = sum(contra, 2)';

f = get_save_figure();
cm = get_cmap([ipsi contra ones(size(ipsi))]);

%% Bilateral map imagesc
subplot(10, 10, [1:4 11:14 21:24 31:34 41:44]);

imagesc([ipsi contra]); axis equal tight; colormap(gca, cm.cm);  caxis(cm.lims);
caxis(cm.lims);
cb = colorbar('southoutside'); ylabel(cb, 'Density');
set(gca, 'XTick', [], 'YTick', yt, 'YTickLabels', {}, 'TickDir', 'out');
xlabel('ipsilateral  \leftarrow  Postsynaptic targets  \rightarrow  contralateral');
ylabel('Presynaptic sources');
title(sprintf('Bilateral connection density (N=%d)', N));

%% Input per node
h = subplot(10, 10, 51:53);
lineplot_subplot(h, ipsi_input, contra_input, true);
ylabel('Total input'); title('Total input per node');

%% Output per node
h = subplot(10, 10, [5 15 25 35 45]);
lineplot_subplot(h, ipsi_output, contra_output, false);
ylabel('Total output');

%% In/output convergence scatter
h = subplot(10, 10, [6:7 16:17 26:27 36:37]);
[mn, mx] = ratioscatter_subplot(h, ipsi_output, ipsi_input, contra_output, contra_input, ...
    'ipsilateral', 'contralateral');
text(mn+0.01, mx, 'Convergent nodes', 'VerticalAlignment', 'top');
text(mx, mn+0.01, 'Divergent nodes', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
xlabel('Output'); ylabel('Input'); title('Summed in/output per node');

%% Hemisphere ratio scatter
h = subplot(10, 10, [9:10 19:20 29:30 39:40]);
ratioscatter_subplot(h, ipsi_input, contra_input, ipsi_output, contra_output, 'inputs', 'outputs');
xlabel('Ipsilateral'); ylabel('Contralateral'); title('Summed in/output per node');

%% In/output convergence boxplot
h = subplot(10, 10, [46:47 56:57]);
convergence = (ipsi_input + contra_input) ./ (ipsi_output + contra_output);
boxplot_subplot(h, convergence, node_regs, node_acros);
ylabel('Convergence ratio');
title('Convergence ratio distributions per brain region');

%% Hemisphere ratio boxplot
h = subplot(10, 10, [49:50 59:60]);
convergence = contra_output ./ ipsi_output;
boxplot_subplot(h, convergence, node_regs, node_acros);
ylabel('Contra over ipsi output');
title('Hemisphere ratio distributions per brain region');

%% Average density per region imagesc
subplot(10, 10, [71:73 81:83 91:93]);
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
title('Average density per region');
cb = colorbar('eastoutside'); ylabel(cb, 'Average density');

%% Bilateral euclidean per region imagesc
subplot(10, 10, [74:76 84:86 94:96]);
[eu, ~] = load_euclidean(ids, ipsi, contra);

avgie = zeros(NR);
avgce = zeros(NR);
for i = 1:NR
    for j = 1:NR
        avgie(i,j) = mean(mean(eu.ipsi(node_regs==i, node_regs==j)));
        avgce(i,j) = mean(mean(eu.contra(node_regs==i, node_regs==j)));
    end
end

imagesc([avgie, avgce]); axis equal tight; colormap(gca, cm.cm);
%set(gca, 'XTick', [], 'YTick', []);
set(gca, 'ticklength', [0 0], 'xtick', 1:2*NR, 'ytick', 1:NR, ...
    'xticklabels', [regions.acro regions.acro], 'yticklabels', [regions.acro]);
cb = colorbar('eastoutside'); ylabel(cb, 'Distance (\mum)');
xlabel('ipsilateral    \leftarrow    Nodes    \rightarrow    contralateral');
ylabel('Nodes');
title('Average distance between nodes per region (\mum)');

%% Dot product imagesc
subplot(10, 10, [77:79 87:89 97:99]);

ipsidot = ipsi .* eu.ipsi;
contradot = contra.* eu.contra;
avgi = zeros(NR);
avgc = zeros(NR);
for i = 1:NR
    for j = 1:NR
        avgi(i,j) = mean(mean(ipsidot(node_regs==i, node_regs==j)));
        avgc(i,j) = mean(mean(contradot(node_regs==i, node_regs==j)));
    end
end

imagesc([avgi, avgc]); axis equal tight; colormap(gca, cm.cm);
hold on;

set(gca, 'ticklength', [0 0], 'xtick', 1:2*NR, 'ytick', 1:NR, ...
    'xticklabels', [regions.acro regions.acro], 'yticklabels', [regions.acro]);
cb = colorbar('eastoutside'); %ylabel(cb, 'Weighted density');
xlabel('ipsilateral    \leftarrow    Nodes    \rightarrow    contralateral');
ylabel('Nodes');
title('Weighted density');

%% Euclidean-density scatter plot
h = subplot(10, 10, [80 90 100]);

dotp = mean([ipsidot contradot], 2);
boxplot_subplot(h, dotp, node_regs, node_acros);
ylabel('Weighted density');
title('Weighted density');

%% Show total ratios
fprintf('%2.1f%% of connectivity is ipsilateral\n', 100*sum(ipsi(:))/sum([ipsi(:);contra(:)]));
autoratio = 0;
%ipsi1 = ipsi - diag(diag(ones(N)));
for i = 1:NR
    autoratio = autoratio + sum(sum(ipsi(node_regs==i, node_regs==i)));
end
autoratio = 100* autoratio / sum(ipsi(:));
fprintf('%2.1f%% of ipsilateral connectivity is contained within a single brain region\n', autoratio);

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end