function [eu, dens] = load_euclidean(ids, ipsi, contra)

if ischar(ids) || isstring(ids)
    load(fullfile(ids, 'data'), 'ids', 'map');
    N = size(map.density, 1);
    ipsi = map.density(:, 1:N);
    contra = map.density(:, N+1:end);
    clear map N;
end

eu = load('euclidean', 'map', 'ids');
[a, b] = ismember(eu.ids, ids);
dens.ids = ids(b(a));
N = length(ids);
dens.ipsi = ipsi(b(a), b(a));
dens.contra = contra(b(a), b(a));
eu = rmfield(eu, 'ids');
eu.map = eu.map(a, [a a]);
eu.ipsi = eu.map(:, 1:N);
eu.contra = eu.map(:, N+1:end);
eu = rmfield(eu, 'map');