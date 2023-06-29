function [map,nodes] = trimmap(map,nodes)
%% Remove disconnected nodes from the network
% This function removes all-zero rows and columns from the adjacency
% matrix. This effectively removes disconnected nodes from the network
% 
% [map,nodes] = trimmap(map,[nodes])
% 
% Input:
% map: projections matrix
% nodes: (optional) list of nodes in the network, e.g. node names or IDs
% 
% Output:
% map: trimmed projections matrix
% nodes: trimmed nodes list (only if nodes parameter is specified)

% Check if network is unilateral or bilateral
if size(map,1) == size(map,2)
    remove = sum(map)==0 | sum(map')==0;
    map(remove,:) = [];
    map(:,remove) = [];
else
    n = size(map,1);
    remove = sum([map(:,1:n);map(:,(n+1):end)])==0 | sum(map')==0;
    map(remove,:) = [];
    map(:,[remove remove]) = [];
end

if nargin == 2
    nodes(remove) = [];
end