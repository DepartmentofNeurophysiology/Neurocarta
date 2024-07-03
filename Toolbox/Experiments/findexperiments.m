function ids = findexperiments(varargin)
%% Find experiments with specific conditions
% For example based on structure ID, strain or gender
% 
% exp_id = findexperiments(Variable, Value, ...)
% exp_id = findexperiments('all')
% 
% Input: either 'all', or a list of Variable-Value pairs where:
% Variable is an experiment property, these are the options:
%   id, name, structure_id, strain, transgenic_line, gender, injectionvol,
%   sum, num_voxels, page_url
% Value is the value of the property (criterium) - string or number
% 
% Output:
% ids: Cell array with experiment IDs
% 
% Example:
% index = findexperiment('gender','M','transgenic_line','Plxnd-Cre-OG')
% Returns all experiments using male mice from transgenic line Plxnd-Cre-OG

load('experiments','experiments');
variables = {'id','name','structure_id','strain','transgenic_line','gender','injectionvol','sum','num_voxels','page_url'};

if nargin == 1
    if strcmpi(varargin{1}, 'all')
        index = 1:length(experiments.id);
    else
        error(['Unknown parameter ' varargin{1}]);
    end
else
    index = true(size(experiments.id));
    for i = 1:2:length(varargin)
        if ~ismember(varargin{i}, variables)
            error(['Unknown variable ' varargin{i}]);
        end
        if ischar(varargin{i+1})
            index = index & strcmp(experiments.(varargin{i}), varargin{i+1});
        else
            index = index & (experiments.(varargin{i}) == varargin{i+1});
        end
    end
end

ids = experiments.id(index);