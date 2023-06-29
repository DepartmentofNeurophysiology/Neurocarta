function targetcount(h,data)
%% Draw bar plot with number of structures targeted
% autocorrelatemap() and crosscorrelatemaps() depend on this function.

load('structures','groups');
subplot(h);
% Create plot with double y-axes
ax = plotyy(0,0,0,0);
hold(ax(1),'on');
hold(ax(2),'on');
gr = length(groups.name); % 15

% Draw bar graph for 15 hyperstructures
n = zeros(gr,1);
for i = 1:gr
    n(i) = sum(data.group==i);
    bar(ax(1),i-0.4,n(i),'BarWidth',0.8,'LineWidth',2,'FaceColor',groups.color(i,:));
end

% Draw line graph for 6 larger hyperstructures
x = [1 3 5.5 8 10 11.5 13.5];
y = sum(n(1:2)); y(2) = sum(n(3:4)); y(3) = sum(n(5:7)); y(4) = sum(n(8:9));
y(5) = sum(n(10:11)); y(6) = n(12); y(7) = sum(n(13:15));
y = y/sum(n);
plot(ax(2),x,y,'Marker','o','LineWidth',1,'Color',[0 0 0]);

% Set axis
set(ax(1),'XLim',[0 gr],'XTick',(1:gr)-0.4,'XTickLabel',groups.acro,...
            'FontSize',8,'box','off','Color','none',...
            'YLim',[0 Inf],'YTickMode','auto','YColor',[0 0 0],...
            'XTickLabelRotation',90);
set(ax(2),'XLim',[0 gr],'FontSize',8,...
            'YLim',[0 1],'YTickMode','auto','YColor',[0 0 0]);
% Set title
t = 'Number of targets';
if length(data.exp_id)==2
    t = sprintf([t '\n(both groups)']);
end
set(h.Title,'String',t,'Units','normalized','Position',[0.5 1 0]);