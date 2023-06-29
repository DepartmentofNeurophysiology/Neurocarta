function [avgc,maxc,nc] = macromap(map,nodes)
% Create a network based on connectivity between hyperstructures, e.g.
% isocortex, hypothalamus, etc. Projection values are either the mean
% (avgc) or max (maxc) of connections between two groups, or the number of
% connections (nc).
% 
% [avgc,maxc,nc] = macromap(map, [nodes])
% 
% Input:
% map: projections matrix (uni- or bilateral)
% nodes: (optional) list of nodes in map - default: nodelist.mat
% 
% Output:
% avgc: macro projections matrix based on average projections
% maxc:  '   '   '   '   '   '   based on maximal projections
% nc: matrix with number of connections between any two groups

load('structures','structures');
if nargin == 1
    load('nodelist','nodelist');
    nodes = nodelist;
end

[~,index] = ismember(nodes,structures.name);
groups = structures.group(index);
n = max(groups); % Number of groups
avgc = zeros(n);
maxc = zeros(n);
nc = zeros(n);

for i = 1:n
    for j = 1:n
        m = map(groups==i,groups==j);
        if max(m(:))>0
            avgc(i,j) = mean(m(:));
            maxc(i,j) = max(m(:));
            nc(i,j) = length(find(m>0));
        end
    end
end

if size(map,1) ~= size(map,2) % Bilateral map
    [a,m,n] = macromap(map(:,(size(map,1)+1):end),nodes);
    avgc = [avgc a];
    maxc = [maxc m];
    nc = [nc n];
end
