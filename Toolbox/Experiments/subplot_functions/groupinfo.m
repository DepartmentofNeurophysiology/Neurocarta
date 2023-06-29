function groupinfo(obj,~,t,g,data,h)
%% Response to a mouse left button click on a structure
% autocorrelatemap() and crosscorrelatemaps() depend on this function.
% 
% obj: handle of clicked graphics object
% t: array of all structures objects
% g: array of all labels objects
% data: data from graph function
% h: plot axes handle

load('structures','groups');
index = obj.UserData;

%% Deselect groups
set(g(:,1),'EdgeColor',[0 0 0]);
set(g(:,2),'Color',[0 0 0]);

%% Deselect targets
set(t(:,1),'EdgeColor','none');
set(t(:,2),'Color',[0 0 0]);

%% If the figure was clicked, display the default info
if index == 0
    startinfo(h(2),data);
    if length(data.inj)==1
        distributions(h([4 6]),data,[]);% Energy and Volume histograms
    end
else
    % Otherwise, highlight selected group
    g(index,1).EdgeColor = [0 0 1];
    g(index,2).Color = [0 0 1];
    % Display information on subplot
    subplot(h(2));
    cla;
    ind = find(data.group==index);
    % Calculate average D,E,I,V
    varnames = {'density','energy','intensity','volume'};
    d = [];
    for i = 1:4
        d = [d mean(data.(varnames{i})(ind,:))];
    end
    % Create string for drawing relevant information
    a = 'Average ';
    v = {[a 'Density'],[a 'Energy'],[a 'Intensity'],[a 'Volume']};
    str = 'Parent Structure Name:\n%s\n\nNumber of Targets: %d\n\n% -24s% 12.8f\n% -24s% 12.8f\n% -24s% 12.8f\n% -24s% 12.8f';
    if length(data.inj) == 1
        str = sprintf(str,groups.name{index},length(ind),v{1},d(1),v{2},d(2),v{3},d(3),v{4},d(4));
    else
        corr = sum(data.color(ind))/length(ind);
        v = [v {[a 'Correlation:']}];
        str = [str '\n% -24s  %.8f\n% -24s  %.8f'];
        str = sprintf(str,groups.name{index},length(ind),v{1},d(1),v{2},d(2),v{3},d(3),v{4},d(4),v{5},-corr,'',corr);
    end
    text(0,1,str,'VerticalAlignment','top','FontName','FixedWidth','FontSize',8);
    if length(data.inj)==1
        distributions(h([4 6]),data,ind);% Energy and Volume histograms
    end
end