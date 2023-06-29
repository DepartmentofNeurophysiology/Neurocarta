function [grp,node] = layereddiagram(h,data)
%% Set dimensions of the graph
% autocorrelatemap() and crosscorrelatemaps() depend on this function.

load('structures','groups','regions');
subplot(h);
set(h,'DataAspectRatio',[1 1 1],'Visible','off','NextPlot','add');
gr = length(groups.name); % Number of hyperstructures, 15

% To do: use coordinates normalized wrt figure window (for window resizing)

dy = ones(gr,1); % Set vertical space between groups
for i = 1:gr
    if isempty(find(data.group==i,1)) % No structures in group,
        dy(i) = 12; % So less space is needed
    else
        dy(i) = 36;
    end
end
y = [0;cumsum(dy)]; % y-coordinates of the groups
y = max(y)-y;
width = 350; % Width of the entire diagram (excluding labels)
d = 6; % Diameter of the node circles

% Convert data correlations [-1,1] to colors [0,1]
if length(data.exp_id)==2
    data.color = data.color/2 +.5;
end

% Allocate memory for graphical objects
grp(gr,2) = matlab.graphics.GraphicsPlaceholder;
node(length(data.name),2) = matlab.graphics.GraphicsPlaceholder;
reg = 1; % For displaying bigger regions on the right
groups.region(gr+1)=length(regions.name)+1;
% Draw background, nodes, node labels, group labels
for i = 1:gr
    % Draw colored background
    grp(i,1) = rectangle('Position',[0 y(i+1) width dy(i)-1],'FaceColor',...
                            groups.color(i,:));
    % Draw parent structure label
    str = [groups.name{i} ' (' groups.acro{i} ')'];
    grp(i,2) = text(width+2,y(i+1)+dy(i)/2,str,'FontSize',7);
    % Draw bigger parent structure label
    if groups.region(i+1)==reg
        str = '';
    else
        str = [regions.name{reg} ' (' regions.acro{reg} ')'];
        reg = reg+1;
    end
    text(-2,y(i+1)+dy(i)/2,str,'FontSize',7,'HorizontalAlignment','right');
    
    index = find(data.group==i); % All nodes from that group
    dx = width/length(index); % Calculate horizontal space between nodes
    x = dx/2;
    for j = index'
        % Draw node circle
        node(j,1) = rectangle('Position',[x-d/2 y(i)-d*1.5 d d],...
                                'Curvature',[1 1],'EdgeColor','none',...
                                'FaceColor',repmat(data.color(j),1,3));
        % Draw structure acronym
        node(j,2) = text(x,y(i)-d*2,data.acro{j},...
                        'Rotation',-90,'FontSize',7,'Margin',1);
        x = x + dx;
    end
end
%set(node(data.inj,2),'FontWeight','bold','FontSize',8);

% Draw correlation gradient bar below layered diagram
set(h,'XLim',[0 width],'YLim',[-10 max(y)]);
cb = colorbar('location','south','color','none','colormap',colormap('gray'));
set(cb,'units','normalized','position',[0.106 0 0.287 0.017],'box','off','ticks',[]);
%set(cb,'units','pixels','position',[135 0 415 13],'box','off','ticks',[]);
set(cb,'ButtonDownFcn',{@changecolormap,node(:,1),data});

if ~iscell(data.exp_id) == 1
    text(width+2,-5,'Projection Energy','FontSize',7);
else
    text(-2,-5,data.label{1},'FontSize',7,'HorizontalAlignment','right');
    text(width+2,-5,data.label{2},'FontSize',7);
end