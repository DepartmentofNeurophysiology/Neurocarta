%% Download and import the AMBCA data
% This process takes a while but needs to be ran only once.
build_database;

%% Top 20 areas targeted by Barrel cortex
% Load metadata
load('experiments', 'experiments');
load('nodelist', 'nodelist');

% Load experiments targeting barrel cortex and average them
barrel_experiments = contains(experiments.injection_site, 'barrel field');
experiment_ids = experiments.id(barrel_experiments);
data = groupexperiments(experiment_ids);

% Display top 20 most strongly targeted areas from barrel cortex
[~, index] = maxk(data.ipsi', 21);
disp('Top 20 areas targeted by Barrel cortex:');
disp(nodelist(index(2:end)));

%% Wildtype network
% Select experiments in wildtype mice
wildtype_exp = findexperiments('strain', 'C57BL/6J', 'transgenic_line', '""');
% Construct the network
network = loadmap('density', 'density', wildtype_exp);
% Create a condensed network
macro_network = macromap(network);

% Create the figure
load('structures', 'groups');
figure;
imagesc(macro_network);
axis image;
set(gca, 'xtick', 1:30, 'xticklabels', [groups.name groups.name]);
set(gca, 'ytick', 1:15, 'yticklabels', groups.name);
title('Average projection density in wildtype mice');
xlabel('Target');
ylabel('Source');

%% Sex comparison
% Group experiments by mouse sex and create two separate networks
male_experiments = findexperiments('gender', 'M');
female_experiments = findexperiments('gender', 'F');
male_network = loadmap('density', 'density', male_experiments);
female_network = loadmap('density', 'density', female_experiments);
male_macro = macromap(male_network);
female_macro = macromap(female_network);
difference = (male_macro - female_macro) ./ (male_macro + female_macro);

% Create the figure
load('structures', 'groups');
figure;
subplot(3, 1, 1); imagesc(male_macro); axis image; colorbar; title('Male');
set(gca, 'xtick', 1:30, 'xticklabels', [groups.name groups.name]);
set(gca, 'ytick', 1:15, 'yticklabels', groups.name);
subplot(3, 1, 2); imagesc(female_macro); axis image; colorbar; title('Female');
set(gca, 'xtick', 1:30, 'xticklabels', [groups.name groups.name]);
set(gca, 'ytick', 1:15, 'yticklabels', groups.name);
subplot(3, 1, 3); imagesc(difference); axis image; colorbar; title('Relative');
set(gca, 'xtick', 1:30, 'xticklabels', [groups.name groups.name]);
set(gca, 'ytick', 1:15, 'yticklabels', groups.name);

%% Finding hubs in wildtype mice
% Select experiments in wildtype mice
wildtype_exp = findexperiments('strain', 'C57BL/6J', 'transgenic_line', '""');
% Construct the network
network = loadmap('density', 'density', wildtype_exp);
% Create a condensed network
macro_network = macromap(network);
% Compute shortest paths in the network
[~, paths] = getpaths(network);
% Compute betweenness centralities
centrality = getcentrality(paths);

% Create the figure
load('nodelist', 'ids');
load('structures', 'structures', 'regions', 'groups');
[~, index] = ismember(ids, structures.id);
figure;
reg = structures.region(index)';
subplot(3, 1, 1); imagesc(network); axis image; colorbar;
subplot(3, 1, 2); imagesc(macro_network); axis image; colorbar;
set(gca, 'xtick', 1:30, 'xticklabels', [groups.name groups.name]);
set(gca, 'ytick', 1:15, 'yticklabels', groups.name);
subplot(3, 1, 3); boxplot(centrality, [reg reg]);
set(gca, 'xticklabels', groups.name);
ylabel('Betweenness centrality');

