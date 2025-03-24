function supp_fig3_gephi(folder)
%% Code for supplemental Figure 3: Mouse brain export to gephi

if nargin == 0
    folder = 'All';
end

load(fullfile(folder, 'data'), 'map', 'nodelist');
load('structures', 'structures');
map = map.density;
map(map<0.005) = 0;

[a, b] = ismember(nodelist, structures.name);
nodelist = nodelist(a);
nodelist = [strcat(nodelist, ' (Right)') ; strcat(nodelist, ' (Left)')];

%colordata = rgb2hex(structures.color(b(a), :));
colordata = structures.color(b(a), :);
colordata = floor(colordata * 255);
colordata = [colordata ; colordata];

colordata = strcat("#", string(dec2hex(colordata(:, 1))), ...
    string(dec2hex(colordata(:, 2))), string(dec2hex(colordata(:, 3))));
colors = struct('name', 'color', 'data', colordata, 'type', 'string');

exportnetwork('supp_fig3_gephi.gexf', nodelist, map, true, colors);