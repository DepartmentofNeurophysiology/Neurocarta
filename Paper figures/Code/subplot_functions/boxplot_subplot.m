function boxplot_subplot(h, data, regs, labels)
%% Boxplot subfigure
load('structures', 'regions');
subplot(h);

cvg_inf = isinf(data);
cvg_zero = data == 0;
cvg_nan = isnan(data);
include = ~(cvg_inf | cvg_zero | cvg_nan);
boxplot(data(include), regs(include), 'BoxStyle', 'outline', ...
    'Colors', regions.color*0.75, 'Symbol', 'x');
ch = get(get(gca, 'Children'), 'Children');
boxes = ch(strcmp(get(ch, 'Tag'), 'Box'));
set(boxes, 'LineWidth', 1);

% Mark outliers with node labels
outliers = ch(strcmp(get(ch, 'Tag'), 'Outliers'));
labels = labels(include);
data = data(include);
for i = 1:length(regions.name)
    xdata = get(outliers(i), 'XData');
    if isnan(xdata)
        continue
    end
    ydata = get(outliers(i), 'YData');
    for j = 1:length(xdata)
        text(xdata(j)+0.1, ydata(j), labels(data==ydata(j)), 'FontSize', 6);
    end
end

set(gca, 'Color', 'none', 'xticklabels', regions.acro);
%xlabel('Brain regions');