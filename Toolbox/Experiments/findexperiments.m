function ids = findexperiments(var,val)
%% Find experiments with specific conditions
% For example experiments where structure_name=='retina'
% Or where strain=='C57BL/6J'
% 
% exp_id = findexperiments(var,val)
% 
% Input:
% var: experiment property, these are the options:
% id, name, structure_id, strain, transgenic_line, gender, injectionvol,
% sum, num_voxels, page_url
% val: value of the property (criterium) - string or number
% 
% Output:
% ids: Cell array with experiment IDs
% 
% Example:
% index = findexperiment('id','100140756');
% Returns the experiment with id 100140756
% 
% Example:
% index = findexperiment('gender','M')
% loadmap('density','density',experiments.id(index))
% Creates a density network based on experiments in males

load('experiments','experiments');
if ischar(val)
    index = find(strcmp(experiments.(var),val));
else
    index = find(experiments.(var)==val);
end
ids = experiments.id(index);