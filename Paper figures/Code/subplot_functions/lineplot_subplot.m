function lineplot_subplot(h, ipsi, contra, input)

subplot(h);
hold on; set(gca,'Color', 'none');
plot(ipsi, 'Color', 'red');
plot(contra, 'Color', 'black');
xlim([0 length(ipsi)]);
ylabel('Total output');

if input
    legend('ipsilateral', 'contralateral', 'Location', 'eastoutside');
else
    legend('ipsilateral', 'contralateral', 'Location', 'southoutside');
    camroll(-90);
end