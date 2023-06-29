function [d,p] = getpaths(map)
%% Calculate the shortest paths between any pair of nodes
% This function calculates the K shortest paths from any node i to node j
% in the network. The length of a path is defined by the sum of the inverse
% projection of the nodes along the path. The shortest path (i,j) is the
% path from i to j for which this path length is minimal.
% 
% [d,p] = getpaths(map)
% 
% Input:
% map: projections matrix (uni- or bilateral)
% 
% Output:
% d: path length matrix, n*m matrix where (i,j) is the pathlength of the
% shortest path from i to j
% p: the shortest paths themselves in a n*n cell matrix where cell (i,j)
% contains the shortest path from i to j. A path constitutes of a list of
% nodes starting with the source and ending with the target.


n = size(map,1);
L = 1./map; % Convert adjacency to length matrix
d = zeros(size(map));
p = cell(size(map));
for i = 1:n
    [d(i,:),p(i,:)] = shortestpath(L,i);
end