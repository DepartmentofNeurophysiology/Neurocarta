function target_sep(h,data)
%% Draw number of targets per brain area for separate experiments
% autocorrelatemap() and crosscorrelatemaps() depend on this function.

load('structures','structures','groups');
subplot(h);
% Create plot with double y-axes
ax = plotyy(0,0,0,0);
hold(ax(1),'on');
hold(ax(2),'on');
gr = length(groups.name); % 15
t = sprintf('Normalized target count\n%s                          %s',data.label{:});

% Sum all values per group
n = zeros(gr,2); nn = n;
for i = 1:gr
    n(i,1) = sum(data.density(data.group==i,1)>0);
    n(i,2) = sum(data.density(data.group==i,2)>0);
    nn(i,:) = n(i,:)/sum(structures.group==i);
end

for i = 1:gr
    barh(ax(1),i-0.4,nn(i,1),'BarWidth',0.8,'LineWidth',2,'FaceColor',groups.color(i,:));
    barh(ax(2),i-0.4,2-nn(i,2),'BarWidth',0.8,'LineWidth',2,'FaceColor',groups.color(i,:),'BaseValue',2);

    y = [2 5 7 9.5 12 14]; % 6 brain regions
    x = [sum(n(1:4,:));sum(n(5:6,:));sum(n(7:8,:));sum(n(9:11,:));sum(n(12:13,:));sum(n(14:15,:))];
    x = x./repmat(sum(n),6,1); % Normalize w.r.t. total
    
    plot(ax(1),x(:,1),y,'Marker','o','LineWidth',1,'Color',[0 0 0]);
    plot(ax(2),2-x(:,2),y,'Marker','o','LineWidth',1,'Color',[0 0 0]);
    
    set(ax(1),'YDir','reverse','YLim',[0 gr],'YTick',(1:gr)-0.4,'YTickLabel',...
        groups.acro,'FontSize',8,'Color','none','box','off','YColor',[0 0 0], ...
        'XLim',[0 2],'XTick',0:0.5:2,'XTickLabel',[0 0.5 1 0.5 0]);
    set(ax(2),'YDir','reverse','YLim',[0 gr],'YTick',(1:gr)-0.4,'YTickLabel',...
        groups.acro,'FontSize',8,'XLim',[0 2],'YColor',[0 0 0]);
    
    line([1 1],[0 gr],'Color',[0 0 0]);
    set(h.Title,'Visible','on','String',t,'Units','normalized',...
        'Position',[0.5 1 0],'HorizontalAlignment','center');
end