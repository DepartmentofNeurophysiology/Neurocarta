function [in,out] = getdegree(map,node)
%% Return the degree of a node (the number of connections in or out)
% 
% [in,out] = getdegree(map,node)
% 
% Input:
% map: projections matrix (uni- or bilateral)
% node: node number(s) - optional, default: all nodes
% 
% Output:
% in: no. of incoming connections
% out: no. of outgoing connections

n = size(map,1);
if nargin == 1
    node = 1:n;
end

if n == size(map,2)
    in = sum(map(:,node)~=0);
else
    in = sum(map(:,node)~=0) + sum(map(:,node+n)~=0);
end

out = sum(map(node,:)~=0,2);