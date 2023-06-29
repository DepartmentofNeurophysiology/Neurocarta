% Remove unrelated directories from path
restoredefaultpath;
clear RESTOREDEFAULTPATH_EXECUTED;
% Add relevant directories to path (if they exist)
addpath(genpath(fullfile(pwd,'Toolbox')));
addpath(fullfile(pwd,'Structures'));
addpath(fullfile(pwd,'Data'));