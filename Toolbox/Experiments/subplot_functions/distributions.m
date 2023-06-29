function distributions(h,data,index)
%% Draw distributions of energy mean and volume mean in line plot
% autocorrelatemap() and crosscorrelatemaps() depend on this function.
% 
% ind: indices of targets that will be counted

if isempty(index)
    data = [data.energy data.volume];
else
    data = [data.energy(index) data.volume(index)];
end

t = {'Energy Distribution','Volume Distribution'};
for i = 1:2
    [n,bins] = histcounts(data(:,i),40);
    bins = bins(1:end-1) + (bins(2)-bins(1))/2;
    plot(h(i),bins,n);
    set(h(i),'XLim',[0 Inf],'YLim',[0 Inf],'FontSize',8,'Color','none','box','off');
    set(h(i).Title,'Visible','on','String',t{i},'Units','normalized',...
                    'Position',[0.5 1 0]);
    h(i).XLim = [0 Inf];
end