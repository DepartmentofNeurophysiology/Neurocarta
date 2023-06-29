function [d,p] = shortestpath(L,source,target)
%% Calculate the shortest path in a graph using Dijkstra's algorithm.
% This function calculates the shortest path from a node i to node j (or
% all other nodes) in the network. The length of a path is defined by the
% sum of the inverse projection of the nodes along the path. The shortest
% path (i,j) is the path from i to j for which this path length is minimal.
% 
% [dist,path] = shortestpath(L,source,[target])
% 
% Input:
% L: length matrix (e.g. dot inverse of projections matrix) (uni- or
% bilateral)
% source: source node
% target: target node (optional, default: all other nodes)
% 
% Output:
% d: path length of the shortest path (number or vector in the case of
% multiple targets).
% p: the shortest path itself. Cell or cell array containing a list of
% nodes that constitute the path, starting with the source and ending with
% the target.

n = size(L,1);
if n ~= size(L,2) % Bilateral map
    L = [L;[L(:,(n+1):(2*n))' L(:,1:n)]];
    n = size(L,1);
end
d = inf(1,n); % distance between source and targets
d(source) = 0;
prev = -ones(1,n); % previous node in shortest path, -1=undefined
q = true(1,n); % unvisited nodes
nodes = 1:n; % list of all nodes

if nargin == 2 % Look for all nodes instead of 1 target node
    target = -1;
end

while sum(q)>0
    % Select closest unvisited node
    [~,k] = min(d(q));
    un = nodes(q); % all unvisited nodes
    u = un(k); % closest unvisited node
    q(u) = false; % node is visited
    
    % If target node is reached, quit
    if u == target
        d = d(u);
        p = [];
        while u~=-1
            p = [u p];
            u = prev(u);
        end
        p = {p}; % Convert to cell for compatibility with other functions
        return;
    end
    
    % For every target: if the new path (via u) is shorter than the old
    % one, replace.
    tdist = d(u) + L(u,:); % temporary distance
    index = tdist<d; % This is not equal to index=L(u,:)>0, because of inf values
    d(index) = tdist(index);
    prev(index) = u;
end

% Calculate paths
p = cell(1,n);
for i = 1:n
    u = i;
    while u~=-1 % Go back along shortest path until source is reached
        p{i} = [u p{i}];
        u = prev(u);
    end
end