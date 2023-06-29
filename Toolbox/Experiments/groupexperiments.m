function groupexperiments(group)
%% Group experiments by averaging the projections
% 
% data = groupexperiments(group)
% 
% Input:
% group: experiment ID of a single experiment file (e.g. '100140756'), or 
% cell array containing multiple IDs. In the latter case the experiments
% will be averaged.
% 
% EXAMPLES
% 
% Get average of projections originating in M1
% mop = {...} % list of experiment IDs
% data = groupexperiments(mop)

if ~iscell(group)
    group = {group};
end

%% Load and format data
proj = {'density','energy','intensity','volume'};
for p = 1:4
    data.(proj{p}) = zeros(length(nodelist),2);
end
for i = 1:length(group)
    fd = load(fullfile('Data',group{i}));
    [found,index] = ismember(nodelist,fd.StructureName);
    for p = 1:4
        data.(proj{p})(found,i) = data.(proj{p})(found,i) + ...
            fd.(hemi{i}).(proj{p})(index(found)) / length(group{i});
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
