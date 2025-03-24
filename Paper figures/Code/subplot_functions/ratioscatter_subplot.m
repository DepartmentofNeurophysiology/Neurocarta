function [mn, mx] = ratioscatter_subplot(h, ipsix, ipsiy, contrax, contray, ipsilabel, contralabel)

subplot(h);
mn = min([ipsix ipsiy contrax contray 0]);
mx = max([ipsix ipsiy contrax contray 0]);
hold on; set(gca, 'Color', 'none'); axis equal tight;
line([mn mx], [mn mx], 'Color', [1 1 1]/2);
xlim([mn mx]); ylim([mn mx]);
s1 = scatter(ipsix, ipsiy, '.', 'red', 'MarkerEdgeAlpha', 0.5);
s2 = scatter(contrax, contray, '.', 'black', 'MarkerEdgeAlpha', 0.5);
legend([s1 s2], ipsilabel, contralabel, 'Location', 'northeast');