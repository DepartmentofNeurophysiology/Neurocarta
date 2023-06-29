function syn = getsynapses(map,threshold)
%% Use the getpaths() function on a binarized map.
% Use getpaths() on a binarized map to get the minimal number of synapses
% between any two nodes i and j.
% 
% syn = getsynapses(map,thr)
% 
% Input:
% map: projections matrix (uni- or bilateral)
% threshold: for filtering map (0%-100%) (optional, default: 0)
% 
% Output:
% syn: n*n matrix where (i,j) is the number of synapses (connections)
% minimally required to get from i to j

if nargin == 2
    map = filtermap(map,threshold) > 0; % Binarize map
else
    map = map > 0;
end

syn = getpaths(map);
