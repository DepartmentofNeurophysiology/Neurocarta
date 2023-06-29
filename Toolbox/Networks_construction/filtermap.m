function [map,thr] = filtermap(map, X)
%% Filter X% of weakest connections from a map.
% 
% [map,thr] = filtermap(map, X)
% 
% Input:
% map: projections matrix (uni- or bilateral)
% X: X% (i.e. 0%-100%) of weakest connections will be filtered
% 
% Output:
% map: filtered projections matrix
% thr: numerical threshold value

values = map(map>0);
sv = sort(values);
ind = max(ceil(length(sv)*(X/100)),1);
thr = sv(ind);
map(map<thr) = 0;