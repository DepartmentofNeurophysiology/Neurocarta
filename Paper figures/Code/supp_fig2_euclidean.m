function supp_fig2_euclidean(folder, save)
%% Supplemental Figure 2: Density vs Euclidean distance
% Subplots/information:
% - Imagesc of difference maps

if nargin == 0
    folder = 'All';
end

[eu, dens] = load_euclidean(folder);
ipsi = dens.ipsi; contra = dens.contra;
load('structures', 'structures', 'regions');
[~, index] = ismember(dens.ids, structures.id);
node_regs = structures.region(index);
node_acros = structures.acro(index);
NR = length(regions.name);

f = get_save_figure();

%% Euclidean distance vs density histograms
edges = linspace(0, max(max([eu.ipsi eu.contra])), 101);
counti = zeros(1, 100);
countc = zeros(1, 100);
densi = zeros(1, 100);
densc = zeros(1, 100);
for i = 1:100
    counti(i) = sum(sum(eu.ipsi>edges(i) & eu.ipsi<=edges(i+1) & ipsi~=0));
    countc(i) = sum(sum(eu.contra>edges(i) & eu.contra<=edges(i+1) & contra~=0));
    densi(i) = sum(sum(abs(ipsi(eu.ipsi>edges(i) & eu.ipsi<=edges(i+1)))));
    densc(i) = sum(sum(abs(contra(eu.contra>edges(i) & eu.contra<=edges(i+1)))));
end
xticks = edges(1:100) + (edges(2)-edges(1))/2;

%{
medci = xticks(find(cumsum(counti)>=sum(counti)/2, 1));
medcc = xticks(find(cumsum(countc)>=sum(countc)/2, 1));
meddi = xticks(find(cumsum(densi)>=sum(densi)/2, 1));
meddc = xticks(find(cumsum(densc)>=sum(densc)/2, 1));
avgci = sum(xticks .* counti) / sum(counti);
avgcc = sum(xticks .* countc) / sum(countc);
avgdi = sum(xticks .* densi) / sum(densi);
avgdc = sum(xticks .* densc) / sum(densc);
%}

%subhist(1, 'Number of connections of any given euclidean distance', '# of connections', counti, countc, medci, medcc, avgci, avgcc);
%subhist(3, 'Sum of densities for all connections of any given euclidean distance', 'Sum of density', densi, densc, meddi, meddc, avgdi, avgdc);

counti = counti/sum(counti);
countc = countc/sum(countc);
densi = densi/sum(densi);
densc = densc/sum(densc);
medci = xticks(find(cumsum(counti)>=0.5, 1));
medcc = xticks(find(cumsum(countc)>=0.5, 1));
meddi = xticks(find(cumsum(densi)>=0.5, 1));
meddc = xticks(find(cumsum(densc)>=0.5, 1));
avgci = sum(xticks .* counti);
avgcc = sum(xticks .* countc);
avgdi = sum(xticks .* densi);
avgdc = sum(xticks .* densc);

%subhist(2, 'Number of connections of any given euclidean distance', '# of connections', counti, countc, medci, medcc, avgci, avgcc);
subhist(1, 'Normalized distribution of number of connections over physical distance', 'Connection probability', ...
    counti, countc, medci, medcc, avgci, avgcc);
subhist(2, 'Normalized distribution of total density over physical distance', 'Density', ...
    densi, densc, meddi, meddc, avgdi, avgdc);
%subhist(4, 'Sum of densities for all connections of any given euclidean distance (normalized to AOC)', 'Sum of density', densi, densc, meddi, meddc, avgdi, avgdc);

    function subhist(n, tt, yl, d1, d2, m1, m2, a1, a2)
        subplot(4, 1, n); hold on;
        b1 = bar(xticks, d1, 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
        b2 = bar(xticks, d2, 'k', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
        l1 = line([m1 m1], [0 max(max([d1 d2]))], 'Color', 'r', 'LineWidth', 2, 'LineStyle', ':');
        l2 = line([m2 m2], [0 max(max([d1 d2]))], 'Color', 'k', 'LineWidth', 2, 'LineStyle', ':');
        l3 = line([a1 a1], [0 max(max([d1 d2]))], 'Color', 'r', 'LineWidth', 2, 'LineStyle', '--');
        l4 = line([a2 a2], [0 max(max([d1 d2]))], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '--');
        lg = legend([b1 b2 l1 l2 l3 l4], 'ipsilateral', 'contralateral', 'median (ipsi)', 'median (contra)', 'mean (ipsi)', 'mean (contra)');
        xlabel('Distance in \mum');
        ylabel(yl);
        title(tt);
        set(gca, 'Color', 'none');
        set(lg, 'Color', 'none');
    end

%% Scatterplot euclidean vs density
subplot(4, 1, 3);
scatter(eu.ipsi(:), ipsi(:), '.', 'red', 'MarkerEdgeAlpha', 0.25);
hold on; set(gca, 'Color', 'none');
scatter(eu.contra(:), contra(:), '.', 'black', 'MarkerEdgeAlpha', 0.25);
xlabel('Distance (\mum)'); ylabel('Density');
legend('Ipsilateral connections', 'Contralateral connections');
title('Relation physical distance vs density');
lims = xlim;

%% Scatterplot condensed euclidean vs density
subplot(4, 1, 4);
eu_avg = zeros(2*NR*NR, 1);
de_avg = zeros(2*NR*NR, 1);
for i = 1:NR
    for j = 1:NR
        eu_avg(2*((i-1)*NR+j)-1) = mean(mean(eu.ipsi(node_regs == i, node_regs == j)));
        eu_avg(2*((i-1)*NR+j)) = mean(mean(eu.contra(node_regs == i, node_regs == j)));
        de_avg(2*((i-1)*NR+j)-1) = mean(mean(ipsi(node_regs == i, node_regs == j)));
        de_avg(2*((i-1)*NR+j)) = mean(mean(contra(node_regs == i, node_regs == j)));
    end
end
scatter(eu_avg(1:2:end), de_avg(1:2:end), 'o', 'red', 'filled');
hold on; set(gca, 'Color', 'none');
scatter(eu_avg(2:2:end), de_avg(2:2:end), 'o', 'black', 'filled');
xlabel('Average distance (\mum)'); ylabel('Average density');
legend('Ipsilateral connections', 'Contralateral connections');
title('Physical distance vs density per larger region');
xlim(lims);

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end

end