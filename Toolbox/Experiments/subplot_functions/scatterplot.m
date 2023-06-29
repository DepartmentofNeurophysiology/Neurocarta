function scatterplot(h,data)
%% Set dimensions of the graph
% draw1experiment() and draw2experiments() depend on this function.

load('structures','groups');
subplot(h);
set(h,'DataAspectRatio',[1 1 1],'Color','None','Box','off','Fontsize',8);
hold on;
gr = length(groups.name); % Number of hyperstructures, 15
n = size(data.density,1);
data.density = data.density ./ repmat(max(data.density),n,1);

for i = 1:gr
    index = data.group == i;
    c = groups.color(i,:) * 0.75;
    tmp = scatter(data.density(index,1),data.density(index,2),16,c,'filled', ...
        'UserData',data.name(index));
    tmp.DataTipTemplate.DataTipRows(3) = dataTipTextRow('Node','UserData');
end

xlabel(data.label{1});
ylabel(data.label{2});
set(h(1).Title,'Visible','on','String','Input per node',...
                'Units','normalized','Position',[0.5 1 0]);