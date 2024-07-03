function download_data
%% Download Allen Mouse Brain Connectivity Atlas in JSON format.

base_url = 'http://connectivity.brain-map.org/api/v2/data/ProjectionStructureUnionize/query.json';
crit_opt = '?criteria=[section_data_set_id$eq%s],[hemisphere_id$ne3]&num_rows=all';
only_opt = '&only=section_data_set_id,structure_id,hemisphere_id,is_injection,projection_density,projection_intensity,projection_energy,projection_volume';
opt = weboptions('TimeOut',120);

load('experiments','experiments');
n = length(experiments.id);

% Number of already imported experiments
nm = length(dir(fullfile('Data','*.json')));
if nm < n
    fprintf('Downloading %d experiments from connectivity atlas...\n',n-nm);
end

tic;
for i = 1:n
    id = experiments.id{i};
    url = [base_url sprintf(crit_opt,id) only_opt];
    fname = fullfile('Data',[id '.json']);
    if exist(fname,'file')~=2
        try
            websave(fname,url,opt);
        catch
            fprintf('Couldn''t download %s.json. Continuing...\n',id);
            if exist(fname,'file')==2
                delete(fname);
            end
        end
    end
    if toc>60 % Display progress every minute
        fprintf('\t%d/%d\n',i,n);
        tic;
    end
end