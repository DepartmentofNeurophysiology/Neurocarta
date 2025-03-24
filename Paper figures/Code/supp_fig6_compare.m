function supp_fig6_compare(folder, save)
%% Supplemental Figure 7: Sex difference in connectivity
% Subplots/information:
% - Imagesc of difference maps

%% Load
if nargin == 0
    folder = 'diff';
end

load(fullfile(folder, 'data'), 'map');
map = map.density;
N = size(map, 1);
ipsi = map(:, 1:N);
contra = map(:, N+1:end);
clear map;

f = get_save_figure();
cm = get_cmap([ipsi contra ones(size(ipsi))]);

%% Bilateral map imagesc
subplot(10, 10, [1:4 11:14 21:24 31:34 41:44]);

imagesc([ipsi contra]); axis equal tight; colormap(gca, cm.cm);  caxis(cm.lims);
caxis(cm.lims);
cb = colorbar('southoutside'); ylabel(cb, 'Density');
set(gca, 'XTick', [], 'YTick', []);
xlabel('ipsilateral  \leftarrow  Postsynaptic targets  \rightarrow  contralateral');
ylabel('Presynaptic sources');
title(sprintf('Bilateral connection density (N=%d)', N));

%% Input per node
h = subplot(10, 10, 51:53);
hold on; set(gca,'Color', 'none');

ipsip = ipsi; ipsip(ipsip<0) = 0;
ipsin = ipsi; ipsin(ipsin>0) = 0;
contrap = contra; contrap(contrap<0) = 0;
contran = contra; contran(contran>0) = 0;
input_p = (sum(ipsip) + sum(contrap)) / (2*N);
output_p = (sum(ipsip, 2)' + sum(contrap, 2)') / (2*N);
input_n = (sum(ipsin) + sum(contran)) / (2*N);
output_n = (sum(ipsin, 2)' + sum(contran, 2)') / (2*N);
clear ipsip ipsin contrap contran

bar(h, input_p, 'EdgeColor', 'none', 'FaceColor', cm.endc);
bar(h, input_n, 'EdgeColor', 'none', 'FaceColor', cm.startc);
plot(h, input_p + input_n, 'Color', cm.middlec);
xlim([0 N]); ylim([-1 1]);
ylabel('Delta input'); title('Delta input per node');

%% Output per node
h = subplot(10, 10, [5 15 25 35]);
hold on; set(gca,'Color', 'none');

bar(h, output_p, 'EdgeColor', 'none', 'FaceColor', cm.endc);
bar(h, output_n, 'EdgeColor', 'none', 'FaceColor', cm.startc);
plot(h, output_p + output_n, 'Color', cm.middlec);
ylabel('Delta output');
xlim([0 N]); ylim([-1 1]);
camroll(-90);

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end