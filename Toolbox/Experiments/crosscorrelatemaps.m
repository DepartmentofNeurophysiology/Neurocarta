function crosscorrelatemaps(group1,group2,labels,hemi)
%% Compare two experiments in a layered diagram
% 
% crosscorrelatemaps(group1,group2,[labels],[hemi])
% 
% Input:
% group1,2: experiment ID of a single experiment file (e.g. '100140756'),
% or cell array containing multiple IDs. In the latter case the experiments
% will be averaged.
% labels (optional): set labels for experiments that will be displayed in
% the plot, e.g. {'group1','group2'}. Default: exp IDs in the case of
% single experiments or {'g1','g2'} in the case of grouped experiments.
% hemi (optional): projections from which hemisphere to use. E.g. set to
% 'contra' to show contralateral projections for both groups or
% {'ipsi','contra'} to show group1 ipsilateral and group2 contralateral.
% (default: 'ipsi' - show ipsilateral projections for both groups)
% 
% EXAMPLES
% 
% Compare ipsilateral projections of two experiments:
% crosscorrelatemaps('100140949','100140756')
% 
% Compare contralateral projections of two experiments:
% crosscorrelatemaps('100140949','100140756',{'m1','v1'},'contra')
% 
% Compare ipsi- vs contralateral projections for one experiment:
% crosscorrelatemaps('100140949','100140949',{'hem1','hem2'},{'ipsi','contra'})
% 
% Compare ipsi- vs contralateral for all experiments injected in MOp:
% mop = {...} % list of experiment IDs
% crosscorrelatemaps(mop,mop,{'hem1','hem2'},{'ipsi','contra'})
% 
% Compare all experiments in MOp to all experiments in SSP:
% mop = {...} % list of experiment IDs
% ssp = {...}
% crosscorrelatemaps(mop,ssp,{'Motor area','Somatosensory area'})
% 
% Compare contralateral projections from MOp for different transgenic lines:
% mop_tl1 = {...} % list of experiment IDs
% mop_tl2 = {...}
% crosscorrelatemaps(mop_tl1,mop_tl2,{'Line 1','Line 2'},'contra')

exp_id = {group1,group2};
if nargin < 3
    if max(length(group1),length(group2)) == 1
        labels = exp_id;
    else
        labels = {'g1','g2'};
    end
end
if nargin < 4
    hemi = {'ipsi','ipsi'};
elseif ~iscell(hemi)
    hemi = {hemi,hemi};
end

for i = 1:2
    if ~iscell(exp_id{i})
        exp_id{i} = {exp_id{i}};
    end
end

load('structures','structures');
load('nodelist','nodelist');

%% Load and format data
disp('Loading data...');
proj = {'density','energy','intensity','volume'};
for p = 1:4
    data.(proj{p}) = zeros(length(nodelist),2);
end
for i = 1:2
    for j = 1:length(exp_id{i})
        fd = load(fullfile('Data',exp_id{i}{j}));
        [found,index] = ismember(nodelist,fd.StructureName);
        for p = 1:4
            data.(proj{p})(found,i) = data.(proj{p})(found,i) + ...
                fd.(hemi{i}).(proj{p})(index(found)) / length(exp_id{i});
        end
    end
end

data.name = nodelist;
[~,index] = ismember(nodelist,structures.name);
data.id = structures.id(index);
data.acro = structures.acro(index);
data.group = structures.group(index);
% Calculate correlation ratios, normalize to [-1 1]
data.color = log(data.volume(:,2).*data.energy(:,2) ...
    ./ (data.volume(:,1).*data.energy(:,1)));
index = abs(data.color)<Inf;
m = max(abs(data.color(index)));
data.color(index) = data.color(index) / m;
data.color(~index) = sign(data.color(~index));
data.exp_id = exp_id; % necessary?
data.label = labels;

% Filter non-targeted structures
index = sum(data.energy,2)==0;
for p = 1:4
    data.(proj{p})(index,:) = [];
end
data.name(index,:) = [];
data.id(index,:) = [];
data.acro(index,:) = [];
data.group(index,:) = [];
data.color(index,:) = [];

%% Create and set figure
disp('Creating figure...');
figure('units','pixels','outerposition',[100 100 1168 610]); % Maximize
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
layereddiagram(leftplot,data);

%% Draw subplots with statistical information
targetcount(handle(1),data);          % Distribution of number of targets per region
target_sep(handle(2),data);           % Distribution of targets per region per experiment
densities(handle([3 5]),data);        % Normalized Energy and Volume density
correlationplots(handle([4 6]),data);
