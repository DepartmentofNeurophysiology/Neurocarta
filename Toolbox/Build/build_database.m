function build_database
%% Download and import Allen Mouse Brain Connectivity Atlas
% 1. Import experiments.csv into MATLAB
% 2. Download AMBCA XML files.
% 3. Import in MATLAB and save as .mat files.
% 4. Define network nodes from injection sites: only structures that are
% the injection site in at least one experiment can be used as nodes.
% 
% This function can be aborted and restarted without losing progress. This
% function depends on structures.mat which contains details about the
% structures defined in the Allen Brain Atlas.

opt = weboptions('TimeOut',15); % Set ping to 15s so that websave doesn't timeout
if exist('Data','dir') ~= 7
    mkdir('Data');
end
if exist('Structures','dir') ~= 7
    mkdir('Structures');
end
startup; % Add folders to path

%% Load structures and URLs necessary to download everything
if exist(fullfile('Structures','nodelist.mat'),'file')~=2
    disp('Downloading default network nodes from Github...');
    nodes_url = 'https://github.com/DepartmentofNeurophysiology/NeuralNet-ABC/blob/main/Structures/nodelist.mat?raw=true';
    websave(fullfile('Structures','nodelist.mat'),nodes_url,opt);
end
if exist('structures.mat','file')~=2
    if exist('structures.json','file')~=2
        disp('Downloading structures.json from ABA...');
        struct_url = 'http://api.brain-map.org/api/v2/structure_graph_download/1.json';
        websave(fullfile('Structures','structures.json'),struct_url,opt);
    end
    disp('Importing structures JSON into Matlab...');
    import_structures('structures.json');
end

%% Download and import latest version of experiments.csv
csv_url = 'http://connectivity.brain-map.org/projection/csv?criteria=service::mouse_connectivity_injection_structure[injection_structures$eq8][primary_structure_only$eqtrue]';
if exist('experiments.mat','file')~=2
    if exist('experiments.csv','file')~=2
        disp('Downloading experiment metadata from ABA...');
        websave(fullfile('Structures','experiments.csv'),csv_url,opt);
    end
    disp('Importing experiment metadata');
    import_exp_data('experiments.csv');
end

%% Download data from API in JSON format
download_data;

%% Import JSON files into MATLAB
import_data;