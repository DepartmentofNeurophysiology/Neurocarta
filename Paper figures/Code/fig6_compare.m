function fig6_compare(folder, save)
%% Figure 6: Sex difference in connectivity
% Subplots/information:
% - Scatterplots comparing in total node in/output
% - Boxplots with ratios

%% Load
if nargin == 0
    folder = 'diff';
end

load('structures', 'structures');
load(fullfile(folder, 'data'), 'm1', 'm2', 'ids', 'cat');
m1 = m1.density;
m2 = m2.density;
N = size(m1, 1);
clear map;

[~, index] = ismember(ids, structures.id);
node_regs = structures.region(index);
node_acros = structures.acro(index);

f = get_save_figure();

%% Input diff scatter
h = subplot(2, 3, 1);
m1i = m1(:, 1:N); m2i = m2(:, 1:N);
m1c = m1(:, N+1:end); m2c = m2(:, N+1:end);
[mn, mx] = ratioscatter_subplot(h, sum(m1i), sum(m2i), sum(m1c), sum(m2c), ...
    'ipsilateral', 'contralateral');
xlim([mn mx]); ylim([mn mx]);
xlabel(cat{1}); ylabel(cat{2}); title('Total input per node');

%% M1 over M2 input boxplot
h = subplot(2, 3, 2);
ratio = sum(m1i + m1c) ./ sum(m2i + m2c);
ratio(isnan(ratio)) = 0;
boxplot_subplot(h, ratio, node_regs, node_acros);
ylabel('Ratio');
title(sprintf('Input ratio per brain region (%s ./ %s)', cat{1}, cat{2}));

%% M2 over M1 input boxplot
h = subplot(2, 3, 3);
ratio = 1./ratio;
boxplot_subplot(h, ratio, node_regs, node_acros);
ylabel('Ratio');
title(sprintf('Input ratio per brain region (%s ./ %s)', cat{2}, cat{1}));

%% Output diff scatter
h = subplot(2, 3, 4);
[mn, mx] = ratioscatter_subplot(h, sum(m1i, 2)', sum(m2i, 2)', sum(m1c, 2)', sum(m2c, 2)', ...
    'ipsilateral', 'contralateral');
xlim([mn mx]); ylim([mn mx]);
xlabel(cat{1}); ylabel(cat{2}); title('Total output per node');

%% M1 over M2 output boxplot
h = subplot(2, 3, 5);
ratio = sum(m1i' + m1c') ./ sum(m2i' + m2c');
ratio(isnan(ratio)) = 0;
boxplot_subplot(h, ratio, node_regs, node_acros);
ylabel('Ratio');
title(sprintf('Output ratio per brain region (%s ./ %s)', cat{1}, cat{2}));

%% M2 over M1 output boxplot
h = subplot(2, 3, 6);
ratio = 1./ratio;
boxplot_subplot(h, ratio, node_regs, node_acros);
ylabel('Ratio');
title(sprintf('Output ratio per brain region (%s ./ %s)', cat{2}, cat{1}));

%% Show total ratios
ratio = sum(sum([m1i m1c]))/ sum(sum([m2i m2c]));
fprintf('%s has %.2f times the total sum of density compared to %s\n', cat{1}, ratio, cat{2});

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end