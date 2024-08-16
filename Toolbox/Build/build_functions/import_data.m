function import_data
%% Import experiment JSON data into MATLAB
% Determine injection hemisphere
% Sort projections into ipsi- vs contralateral

% Projections variable names
proj = {'density','energy','intensity','volume'};
proj1 = strcat('projection_',proj);
load('structures','structures');
load('experiments','experiments');
load('nodelist','nodelist');

n = length(experiments.id);
if ~isfield(experiments,'injection_site')
    experiments.injection_site = cell(n,1);
end

% Number of already imported experiments
nm = length(dir(fullfile('Data','*.mat')));
fprintf('Importing %d experiment files into MATLAB...\n',n-nm);

tic;
for i = 1:n
    if exist(fullfile('Data',[experiments.id{i} '.mat']),'file')==2
        continue;
    end
    
    % Load data
    str = fileread(fullfile('Data',[experiments.id{i} '.json']));
    try
        d = jsondecode(str);
        d = d.msg; % data in struct format
    catch ME
        if ~strcmp(ME.identifier,'MATLAB:webservices:OperationTerminatedByUser')
            fprintf('Couldn''t parse %s.json, try deleting file and rerunning build_database. Continuing...\n', experiments.id{i});
            continue;
        else
            throw(ME);
        end
    end

    % Create empty data structure
    StructureID = [];
    StructureName = [];
    hidnr = [0 0];
    for p = 1:4
        hem(1).(proj{p}) = []; % Left hemisphere data
        hem(2).(proj{p}) = []; % Right hemisphere data
    end

    for j = 1:length(d)
        if ~ismember(d(j).structure_id,structures.id) % ignore unknown structures
            continue;
        end
        found = find(d(j).structure_id==StructureID,1);
        if isempty(found)
            StructureID = [StructureID;d(j).structure_id];
            StructureName = [StructureName;structures.name(structures.id==d(j).structure_id)];
            found = length(StructureID); % add new structure at end
            for h = 1:2
                for p = 1:4
                    hem(h).(proj{p})(found) = 0;
                end
            end
        end

        % add data to data structure
        h = d(j).hemisphere_id;
        if d(j).is_injection==1 % injection site: add or replace
            hidnr(h) = hidnr(h) + 1;
            for p = 1:4
                hem(h).(proj{p})(found) = d(j).(proj1{p});
            end
        elseif hem(h).density(found)==0 % other: only add, don't replace
            for p = 1:4
                hem(h).(proj{p})(found) = d(j).(proj1{p});
            end
        end
    end
    
    % Determine injection hemisphere and divide projections into ipsi- vs contralateral
    % Use three measures to determine injection hemisphere:
    % % the one with the most injection structures;
    % % the one with the biggest sum of projection densities;
    % % and the one with the highest projection density
    [~, hidnr] = max(hidnr);
    [~, sumnr] = max([sum(hem(1).density), sum(hem(2).density)]);
    [~, maxnr] = max([max(hem(1).density), max(hem(2).density)]);
    % Ignore experiments where the measures are not consistent
    if hidnr ~= sumnr || hidnr ~= maxnr || sumnr ~= maxnr
        continue
    end
    HemisphereID = hidnr;
    ipsi = hem(HemisphereID);
    contra = hem(3-HemisphereID);
    
    % Determine injection site by maximum projection density and normalize
    [~,ix] = sort(ipsi.density,'descend');
    for j = 1:length(ix)
        if ismember(StructureName(ix(j)),nodelist)
            break;
        end
    end
    experiments.injection_site(i) = StructureName(ix(j));
    
    for p = 1:4
        contra.(proj{p}) = contra.(proj{p})' / ipsi.(proj{p})(ix(j));
        ipsi.(proj{p}) = ipsi.(proj{p})' / ipsi.(proj{p})(ix(j));
    end
    
    save(fullfile('Data',experiments.id{i}), ...
        'StructureID','StructureName','HemisphereID','ipsi','contra');
    
    nm = nm + 1;
    % Display progress every minute
    if toc>60
        fprintf('\t%d/%d\n',nm,n);
        tic;
    end
end

save('experiments','experiments','-append');