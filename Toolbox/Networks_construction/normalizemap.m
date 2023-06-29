function map_normal = normalizemap(map)
% Normalize connections w.r.t to the global maximum, confining connection
% strengths to the interval [0,1].
% 
% map_normal = normalizemap(map)
% 
% Input:
% map: projections matrix (uni- or bilateral)
% 
% Output:
% map_normal: normalized map

map_normal = map ./ repmat(max(map,[],2),1,size(map,2));