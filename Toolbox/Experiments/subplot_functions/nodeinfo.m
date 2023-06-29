function nodeinfo(obj,~,t,g,data,h)
%% Response to a mouse left button click on a structure
% autocorrelatemap() and crosscorrelatemaps() depend on this function.
%
% obj: handle of clicked graphics object
% t: array of all structures objects
% g: array of all labels objects
% data: data from graph function
% h: plot axes handle

%% Deselect groups
set(g(:,1),'EdgeColor',[0 0 0]);
set(g(:,2),'Color',[0 0 0]);

%% Deselect other targets, highlight selected target
set(t(:,1),'EdgeColor','none');
set(t(:,2),'Color',[0 0 0]);
index = obj.UserData;
t(index,1).EdgeColor = [0 0 1];
t(index,2).Color = [0 0 1];

%% Display information on subplot
subplot(h(2));
cla;
v = {'density','energy','intensity','volume'};
if length(data.inj) == 1
    d = [data.(v{1})(index,:) data.(v{2})(index,:) data.(v{3})(index,:) data.(v{4})(index,:)];
    str = 'Structure Name:\n%s (%s)\n\n% -16s% 12.8f\n% -16s% 12.8f\n% -16s% 12.8f\n% -16s% 12.8f';
    str = sprintf(str,data.name{index},data.acro{index},v{1},d(1),v{2},d(2),v{3},d(3),v{4},d(4));
else
    v = [{'Experiment:'} v {'Correlation:'}];
    d = [data.Density(index,:) data.Energy(index,:) data.Intensity(index,:) data.Volume(index,:)];
    d = [d -data.color(index) data.color(index)];
    str = 'Structure Name:\n%s (%s)\n\n% -16s% 12s % 12s\n% -16s% 12.8f % 12.8f\n% -16s% 12.8f % 12.8f\n% -16s% 12.8f % 12.8f\n% -16s% 12.8f % 12.8f\n% -16s% 12.4f % 12.4f';
    str = sprintf(str,data.name{index},data.acro{index},v{1},data.label{1},data.label{2},v{2},d([1 2]),v{3},d([3 4]),v{4},d([5 6]),v{5},d([7 8]),v{6},d([9 10]));
end
text(0,1,str,'VerticalAlignment','top','FontName','FixedWidth','FontSize',8);

%% Set default histograms
if length(data.inj)==1
    distributions(h([4 6]),data,[]);
end