function map = loadmap(var,src,experiments,nodelist)
% This function creates a weighted, directed graph based on the projections
% data. For every experiment a source node (injection site) is determined
% and the connection strength from source node to target nodes is equal to
% the projection strength. Target structures can be ipsi- or contralateral
% with respect to the source structure. When a source-target combination
% occurs more than once, the average projection is stored in the adjacency
% matrix.
% 
% map = loadmap(var,[src],[experiments],[nodelist])
%
% Input:
% var: variable used for adjacency (e.g. 'energy', 'density', ...)
% src: (optional, default=same as var) variable used to determine source
% structure for projections
% experiments: (optional) cell array of experiment IDs to use
% nodelist: (optional) list of node acronyms to use
% 
% Output:
% map: bilateral (n*2n) network based on projections data. Left half of the
% matrix contains ipsilateral connections, right half contralateral
% connections. Matrix entry (i,j) encodes the connection strength from node
% i to node j.

% Set default parameters
if nargin < 2
    src = var;
end
if nargin < 3 || isempty(experiments)
    load('experiments', 'experiments');
    d = experiments.id;
    clear experiments;
else
    d = fullfile('Data',experiments);
end
if nargin < 4
    load('nodelist','nodelist');
end

disp('Loading experiments...');
n = length(nodelist);
map = zeros(n,2*n);
n_src = zeros(n,1);
tic;
for i = 1:length(d)
    if exist([d{i} '.mat'], 'file') ~= 2
        continue
    end
    data = load(d{i},'ipsi','contra','StructureName');
    data_ipsi = zeros(1,n);
    data_contra = zeros(1,n);
    data_src = zeros(1,n);
    [found,index] = ismember(data.StructureName,nodelist);
    data_ipsi(index(found)) = data.ipsi.(var)(found);
    data_contra(index(found)) = data.contra.(var)(found);
    data_src(index(found)) = data.ipsi.(src)(found);
    [~,source] = max(data_src);
    map(source,:) = map(source,:) + [data_ipsi data_contra];
    n_src(source) = n_src(source) + 1;
    
    if toc > 60 % Display progress every minute
        fprintf('\t%d/%d\n',i,length(d));
        tic;
    end
end

% Take average of experiments with identical injection site
map(n_src>0,:) = map(n_src>0,:) ./ repmat(n_src(n_src>0),1,2*n);