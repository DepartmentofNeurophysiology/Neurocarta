function correlationplots(h,data)
%% Draw plots showing relative input distribution
% autocorrelatemap() and crosscorrelatemaps() depend on this function.

load('structures','groups');
axlabels1 = {data.label{1},'0.5','0','0.5',data.label{2}};
axlabels2 = {data.label{1},'0.75','0.5','0.25','0','0.25','0.5','0.75',data.label{2}};

% Draw boxplot
glabel = cell(length(data.id),1);
for i = 1:length(data.id)
    glabel{i} = groups.acro{data.group(i)};
end
for i = 1:length(groups.name)
    if isempty(find(strcmp(glabel,groups.acro{i}),1)) % group is not targeted
        % Add -2 value so that group is still displayed in boxplot
        data.color = [data.color;-2];
        glabel = [glabel;groups.acro{i}];
    end
end
% Change group order using GroupOrder property
boxplot(h(1),data.color,glabel,'GroupOrder',groups.acro);
set(h(1),'FontSize',8,'Color','none','box','off');
set(h(1),'YLim',[-1 1],'YTick',-1:0.25:1,'YTickLabel',axlabels2,...
         'XTickLabelRotation',90);
set(h(1).Title,'Visible','on','String','Relative input per region',...
                'Units','normalized','Position',[0.5 1 0]);

% Draw histogram
[n,bins] = histcounts(data.color,40);
bins = bins(1:end-1) + (bins(2)-bins(1))/2;
plot(h(2),bins,n/max(n));
set(h(2),'YLim',[0 Inf],'FontSize',8,'Color','none','box','off');
set(h(2),'XLim',[-1 1],'XTick',-1:0.25:1,'XTickLabel',axlabels2);
set(h(2).Title,'Visible','on','String','Relative input distribution',...
                'Units','normalized','Position',[0.5 1 0]);