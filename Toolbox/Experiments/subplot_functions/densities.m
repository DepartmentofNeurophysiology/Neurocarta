function densities(h,data)
%% Draw energy density and volume density per hyperstructure, in bar plot
% autocorrelatemap() and crosscorrelatemaps() depend on this function.

load('structures','groups');
t = {'Normalized Energy Density','Normalized Volume Density'};
no = length(data.exp_id); % Number of experiments to show (auto-corr vs cross-corr)
gr = length(groups.name); % Number of hyperstructures (15)

% Copy all energy and volume values from data into d
em = data.energy;
vm = data.volume;
if no==2
    t{1} = sprintf([t{1} '\n%s                          %s'],data.label{:});
    t{2} = sprintf([t{2} '\n%s                          %s'],data.label{:});
end
% Sum all values per group
n = zeros(gr,no,2);
for i = 1:gr
    n(i,:,1) = sum(em(data.group==i,:));
    n(i,:,2) = sum(vm(data.group==i,:));
end

% Normalize group Energies
for i = 1:no
    n(:,i,1) = n(:,i,1) / sum(n(:,i,1));
    n(:,i,2) = n(:,i,2) / sum(n(:,i,2));
end

for i = 1:2
    subplot(h(i));
    if no == 1 % Single experiment bar plot
        hold on;
        for j = 1:gr
            bar(h(i),j-0.4,n(j,1,i),'BarWidth',0.8,'LineWidth',2,...
                    'FaceColor',groups.color(j,:));
        end
        set(h(i),'XLim',[0 gr],'XTick',(1:gr)-0.4,'XTickLabel',groups.acro,...
            'FontSize',8,'Color','none','box','off','YLim',[0 1],...
            'YTickMode','auto','XtickLabelRotation',90);
    else % Multiple experiments
        % Create double y-axes
        ax = plotyy(0,0,0,0);
        hold(ax(1),'on');
        hold(ax(2),'on');
        % Create bars
        n(:,2,i) = 2 - n(:,2,i);
        for j = 1:gr
            barh(ax(1),j-0.4,n(j,1,i),'BarWidth',0.8,'LineWidth',2,...
                        'FaceColor',groups.color(j,:));
            barh(ax(2),j-0.4,n(j,2,i),'BarWidth',0.8,'LineWidth',2,...
                        'FaceColor',groups.color(j,:),'BaseValue',2);
        end
        set(ax(1),'YDir','reverse','YLim',[0 gr],'YTick',(1:gr)-0.4,'YTickLabel',...
                groups.acro,'FontSize',8,'Color','none','box','off','YColor',[0 0 0],...
                'XLim',[0 2],'XTick',[0 0.5 1 1.5 2],'XTickLabel',[0 0.5 1 0.5 0]);
        set(ax(2),'YDir','reverse','YLim',[0 gr],'YTick',(1:gr)-0.4,'YTickLabel',...
                groups.acro,'FontSize',8,'XLim',[0 2],'YColor',[0 0 0]);
        line([1 1],[0 gr],'Color',[0 0 0]);
    end
    set(h(i).Title,'Visible','on','String',t{i},'Units','normalized',...
                    'Position',[0.5 1 0],'HorizontalAlignment','center');
end