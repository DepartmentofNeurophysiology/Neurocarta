function autocorrelatemap(exp_id,hemisphere)
%% Show overview of experiment statistics
% 
% autocorrelatemap(exp_id,[hemisphere])
% 
% Input:
% exp_id: experiment id of experiment file (e.g. '100140756')
% hemisphere: set to 'contra' to show contralateral projections (default:
% 'ipsi' - show ipsilateral projections only)
% 
% TO DO: allow for grouping experiments

if nargin == 1
    hemisphere = 'ipsi';
end

%% Format data suitable for drawing functions
proj = {'density','energy','intensity','volume'};
file_data = load(fullfile('Data',exp_id));
load('structures','structures');
load('nodelist','nodelist');

[found,index] = ismember(nodelist,file_data.StructureName);
for p = 1:4
    data.(proj{p}) = zeros(length(nodelist),1);
    data.(proj{p})(found) = file_data.(hemisphere).(proj{p})(index(found));
end
[~,data.inj] = max(file_data.ipsi.energy(index(found)));
data.label = nodelist(data.inj);
data.name = nodelist;
[~,index] = ismember(nodelist,structures.name);
data.id = structures.id(index);
data.acro = structures.acro(index);
data.group = structures.group(index);
data.color = data.energy / max(data.energy);
data.exp_id = exp_id;

% Filter non-targeted structures
index = data.energy==0;
for p = 1:4
    data.(proj{p})(index) = [];
end
data.name(index) = [];
data.id(index) = [];
data.acro(index) = [];
data.group(index) = [];
data.color(index) = [];

%% Create and set figure
figure('units','normalized','outerposition',[0 0 1 1]); % Maximize figure
leftplot = subplot(3,4,[1 2 5 6 9 10]);
index = [3 4 7 8 11 12]; % Smaller subplots
for i = 1:6
    handle(i) = subplot(3,4,index(i));
end

% Set position of the subplots
margin = 0.03; % Margin space between subplots
leftplot.Position = [margin 0 0.5-2*margin 1];
for i = 1:3
    handle(i*2-1).Position = [0.5+margin 1+margin-i/3 0.25-2*margin 0.3-2*margin];
    handle(i*2).Position = [0.75+margin 1+margin-i/3 0.25-2*margin 0.3-2*margin];
end

%% Draw layered diagram on the left
[grp,node] = layereddiagram(leftplot,data);

%% Draw subplots with statistical information
targetcount(handle(1),data);          % Distribution of number of targets per region
startinfo(handle(2),data);            % General information about experiment
densities(handle([3 5]),data);        % Normalized Energy and Volume density
distributions(handle([4 6]),data,[]); % Energy and Volume histograms

% Define the interactive element with the nodes
for i = 1:length(data.name)
    set(node(i,1),'UserData',i,'ButtonDownFcn',{@nodeinfo,node,grp,data,handle});
    set(node(i,2),'UserData',i,'ButtonDownFcn',{@nodeinfo,node,grp,data,handle});
end
% Define the interactive element with the group labels and bars
for i = 1:15
    for j = 1:2
        set(grp(i,j),'UserData',i,'ButtonDownFcn',{@groupinfo,node,grp,data,handle});
    end
end
% Define the interaction with the figure
set(gcf,'UserData',0,'ButtonDownFcn',{@groupinfo,node,grp,data,handle});