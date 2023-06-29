function import_structures(jsonfile)
%% Import structures ontology from Allen Brain Map into Matlab
% Explanation of structures.level:
% % 2: regions, see structures.region
% % 1: groups, see structures.group
% % 0: the rest of the nodes

grouplist = {'Isocortex','Olfactory areas','Hippocampal formation','Cortical subplate',...
    'Striatum','Pallidum','Thalamus','Hypothalamus','Midbrain, sensory related',...
    'Midbrain, motor related','Midbrain, behavioral state related','Pons','Medulla',...
    'Cerebellar cortex','Cerebellar nuclei'};
regionlist = {'Cerebral cortex','Cerebral nuclei','Interbrain','Midbrain','Hindbrain','Cerebellum'};

group_acro = {'ISO';'OLF';'HPF';'CSP';'STR';'PAL';'TH';'HY';'MBs';'MBm';'MBs';'PS';'MD';'CBX';'CBN'};

%% Load and parse data
str = fileread(jsonfile);
data = JSON.parse(str);
data = data.msg{1}.children{1};

%% Set tree root
structures.name = {data.name};
structures.acro = {data.acronym};
structures.id = data.id;
structures.color = sscanf(data.color_hex_triplet,'%2x')'/255; % Convert HEX color to RGB
structures.parent_index = 0;
structures.child_index = {[]};
structures.level = 0;
structures.group = 0;
structures.region = 0;

%% Convert tree->list
for i = 1:length(data.children)
    listtree(data.children{i});
end

% Fill in 'child_index' fields
for i = 2:length(structures.id)
    structures.child_index{structures.parent_index(i)} = ...
        [structures.child_index{structures.parent_index(i)} i];
end

reg_index = find(structures.level==2);
regions.name = structures.name(reg_index);
regions.acro = structures.acro(reg_index);
regions.color = structures.color(reg_index,:);
gr_index = find(structures.level==1);
groups.name = group_acro;
groups.acro = structures.acro(gr_index);
groups.color = structures.color(gr_index,:);
groups.region = structures.region(gr_index);

save(fullfile('Structures','structures'),'structures','regions','groups');

    function listtree(d)
    %% Expand tree to list
        myparent = find(structures.id==d.parent_structure_id,1);
        structures.name = [structures.name;d.name];
        structures.acro = [structures.acro;{d.acronym}];
        structures.id = [structures.id;d.id];
        % Convert HEX color to RGB
        structures.color = [structures.color;sscanf(d.color_hex_triplet,'%2x')'/255];
        structures.parent_index = [structures.parent_index;myparent];
        structures.child_index = [structures.child_index;{[]}];
        structures.group = [structures.group;structures.group(myparent)];
        structures.region = [structures.region;structures.region(myparent)];

        if ismember(d.name,regionlist)
            structures.level = [structures.level;2];
            structures.region(end) = find(strcmp(d.name,regionlist),1);
        elseif ismember(d.name,grouplist)
            structures.level = [structures.level;1];
            structures.group(end) = find(strcmp(d.name,grouplist),1);
        else
            structures.level = [structures.level;0];
        end
        for j = 1:length(d.children)
            listtree(d.children{j});
        end
    end
end