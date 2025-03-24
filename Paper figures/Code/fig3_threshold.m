function fig3_threshold(folder, save)
%% Figure 3: Connection numbers
% Subplots/information:
% - Although weaker, contralateral projections are more numerous
% - Show density imagesc normalized separately
% - Show number of projections ipsilaterally vs contralaterally vs threshold

%% Load and normalize
if nargin == 0
    folder = 'All';
end

load('structures', 'structures', 'regions');
load(fullfile(folder, 'data'), 'map', 'ids');
N = size(map.density, 1);
ipsi = map.density(:, 1:N);
contra = map.density(:, N+1:end);
clear map;

[~, index] = ismember(ids, structures.id);
node_regs = structures.region(index);
NR = length(regions.name);

f = get_save_figure();

%% Bilateral map imagesc with hemispheric normalization
subplot(3, 4, 1:4);
contran = contra;
for i = 1:N
    contran(i, :) = contran(i, :) / max(abs(contran(i, :)));
end
cm = get_cmap([ipsi contran]);
imagesc([ipsi contran]); axis equal tight; colormap(gca, cm.cm); caxis(cm.lims);
cb = colorbar('eastoutside'); ylabel(cb, 'Density');
caxis([-(min(min([ipsi contra])) < 0), 1]);
set(gca, 'XTick', [], 'YTick', []);
xlabel('ipsilateral  \leftarrow  Postsynaptic targets  \rightarrow  contralateral');
ylabel('Presynaptic sources');
title('Bilateral connection density (normalized separately)');

%% Average density per region
subplot(3, 4, 5:8);
avgi = zeros(NR);
avgc = zeros(NR);
for i = 1:NR
    for j = 1:NR
        avgi(i,j) = mean(mean(ipsi(node_regs==i, node_regs==j)));
        avgc(i,j) = mean(mean(contran(node_regs==i, node_regs==j)));
    end
end
cm = get_cmap([avgi avgc]);
imagesc([avgi avgc]); axis equal tight; colormap(gca, cm.cm); caxis(cm.lims);
set(gca, 'ticklength', [0 0], 'xtick', 1:2*NR, 'ytick', 1:NR, ...
    'xticklabels', [regions.acro regions.acro], 'yticklabels', [regions.acro]);
xlabel('ipsilateral \leftarrow Postsynaptic targets \rightarrow contralateral');
ylabel('Presynaptic sources');
title('Average density per region (normalized separately)');
cb = colorbar('eastoutside'); ylabel(cb, 'Average density');

%% No. of connections as a function of (a.f.o.) threshold
subplot(3, 4, 10:11);
thr = [0 logspace(-5, 0, 51)];
NT = length(thr);
ipsi_conn = zeros(1, NT);
contra_conn = zeros(1, NT);
contran_conn = zeros(1, NT);
for i = 1:NT
    ipsi_conn(i) = 100*mean(mean(abs(ipsi) > thr(i)));
    contra_conn(i) = 100*mean(mean(abs(contra) > thr(i)));
    contran_conn(i) = 100*mean(mean(abs(contran) > thr(i)));
end
hold on; set(gca, 'Color', 'none');
plot(ipsi_conn, 'r'); plot(contra_conn, 'k'); plot(contran_conn, 'k--');
xlim([1 inf]);
set(gca, 'xtick', [1 2:10:52], 'xticklabels', ["0" "1e"+string(-5:-1) "1"]);
legend('ipsilateral', 'contralateral', 'contralateral (normalized separately)');
title('No. of ipsi-/contralateral connections for increasing threshold');
ylabel('% of connections left'); xlabel('Threshold (applied to density)');

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end