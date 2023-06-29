function [d,p] = getkpaths(map,K)
%% Calculate the K shortest paths between any pair of nodes
% This function calculates the K shortest paths from any node i to node j
% in the network. The length of a path is defined by the sum of the inverse
% projection of the nodes along the path. The shortest path (i,j) is the
% path from i to j for which this path length is minimal.
% 
% [d,p] = getkpaths(map,K)
% 
% Input:
% map: projections matrix (uni- or bilateral)
% K: number of shortest paths to find
% 
% Output:
% d: path length matrix, n*m*K matrix where (i,j,k) is the pathlength of
% the kth shortest path from i to j.
% p: the shortest paths themselves in a n*m*K cell matrix where cell
% (i,j,k) contains the kth shortest path from i to j. A path constitutes of
% a list of nodes starting with the source and ending with the target.

%% This script works suboptimal for K=1. Instead, use getpaths(map).

n = size(map,1);
m = size(map,2);
L = 1./map; % Convert adjacency to length matrix
d = zeros(n,m,K);
p = cell(n,m,K);
tic;
for i = 1:n
    for j = 1:m
        if toc > 60
            disp(((i-1)*m+j)/(n*m));
        end
        [d(i,j,:),p(i,j,:)] = kshortestpaths(L,K,i,j);
    end
end