function generate_maps(category)
%% Generate maps
% This function should generate all maps used for the figures, and store them
% in designated folders with their respective figures or something?

%% Select experiments, folder etc.
if nargin == 0
    category = 'All';
elseif ~ischar(category)
    category = char(category);
end

disp(['Generating maps for ' category]);

if ismember(category, {'Inhibitory', 'Excitatory', 'Uncategorized'})
    % Load celltype-specific experiments
    load('transgenic_lines', 'data');
    data = data(strcmp(data(:, 2), category), 1);
    exp_ids = [];
    for i = 1:length(data)
        exp_ids = [exp_ids;findexperiments('transgenic_line',data{i})];
    end
    exp_ids = unique(exp_ids);
elseif ismember(category, {'Male', 'Female'})
    % Load sex-specific experiments
    exp_ids = findexperiments('gender', category(1)); % 'M' or 'F'
elseif strcmpi(category, 'All')
    exp_ids = {};
else
    error(['Unknown category ' category]);
end

if exist(category, 'dir') ~= 7
    mkdir(category);
end
fname = fullfile(category, 'data');

%% Load maps
disp('Loading maps');
mode = {'density', 'intensity', 'energy'};
for m = 1:3
    map.(mode{m}) = loadmap(mode{m}, 'density', exp_ids); % inj selection also variable?
    % currently, experiments.injection_site contains structure with maximum
    % density. However, loadmap selects structure with maximum (src) as
    % injection site. Try using both?
end
experiment_ids = exp_ids;
load('nodelist', 'nodelist', 'ids');

% Trim disconnected nodes - this is mode independent
N = size(map.density, 1);
%include = sum(map.density(:,1:N)+map.density(:,N+1:end))>0 & sum(map.density')>0;
include = sum(map.density, 2) > 0; % Only exclude non-source nodes
nodelist = nodelist(include);
ids = ids(include);
for m = 1:3
    map.(mode{m}) = map.(mode{m})(include, [include include]);
end

save(fname, 'map', 'nodelist', 'ids', 'experiment_ids');

%% Calculate DOS
disp('Calculating DOS for 20 different thresholds');
thresholds = 0:5:95;
nt = length(thresholds);
for m = 1:3
    fprintf('\t%s\n', mode{m});
    dos.(mode{m}) = cell(nt, 1);
    for i = 1:nt
        dos.(mode{m}){i} = getsynapses(map.(mode{m}), thresholds(i));
    end
end

save(fname, 'dos', 'thresholds', 'mode', '-append');

%% Calculate paths
disp('Calculating paths');
for m = 1:3
    fprintf('\t%s\n', mode{m});
    [dist.(mode{m}), path.(mode{m})] = getpaths(map.(mode{m}));
    pathdos.(mode{m}) = cellfun(@length, path.(mode{m})) - 1;
end

save(fname, 'dist', 'path', 'pathdos', '-append');

%% Calculate betweenness centrality
disp('Calculating betweenness centrality');
for m = 1:3
    fprintf('\t%s\n', mode{m});
    ct.(mode{m}) = getcentrality(path.(mode{m}));
end

save(fname, 'ct', '-append');