function import_exp_data(csvfile)
%% Import experiment metadata from experiments.csv
% Read csv file and write experiment details to data structure.
% 
% This function depends on a file experiments.csv which contains metadata
% from all relevant experiments, retrieved from connectivity.brain-map.org.

% FormatSpec defined to read data from CSV file
%format1 = '%[^,],%[^,],%f,%*[^"]"%*[^"]",%*[^,],%[^,],%[^,],%[^,],"[%f, %f, %f]",%f,"[%*[^]]]",%*f,%f,%f,%*[^,],%s';
%format2 = '%[^,],%[^,],%f,%*[^,],%*[^,],%*[^,],%[^,],%[^,],%[^,],"[%f, %f, %f]",%f,"[%*[^]]]",%*f,%f,%f,%*[^,],%s';
format1 = '%[^,],%[^,],%*f,%f,%*[^"]"%*[^"]",%[^,],%f,"[%*[^]]]",%c,%[^,],%f,%*[^,],,"[%f, %f, %f]",%*[^,],%s';
format2 = '%[^,],%[^,],%*f,%f,%*[^,],%*[^,],%[^,],%f,"[%*[^]]]",%c,%[^,],%f,%*[^,],,"[%f, %f, %f]",%*[^,],%s';

f = fopen(csvfile);
lns = textscan(f,'%s','HeaderLines',1,'Delimiter','\n');
lns = lns{1};
n = length(lns);
experiments.id = cell(n,1); % Experiment ID
experiments.name = cell(n,1); % Experiment name
experiments.structure_id = zeros(n,1); % Injection structure ID
experiments.strain = cell(n,1); % Mouse strain
experiments.transgenic_line = cell(n,1); % Transgenic line
experiments.gender = cell(n,1); % Mouse gender
experiments.injectionloc = zeros(n,3); % Injection location
experiments.injectionvol = zeros(n,1); % Injection volume
experiments.sum = zeros(n,1); % Sum??
experiments.page_url = cell(n,1); % Experiment page url

for i = 1:n
    tags = textscan(lns{i},'%*[^,],%*[^,],%*[^,],%*[^,],%*[^,],%[^,],',1);
    if tags{1}{1}(1)=='"' % Structure name contains comma
        tags = textscan(lns{i},format1);
    else
        tags = textscan(lns{i},format2);
    end
    experiments.id(i) = tags{1};
    experiments.name(i) = tags{4};
    experiments.structure_id(i) = tags{3};
    experiments.strain(i) = tags{7};
    experiments.transgenic_line(i) = tags{2};
    experiments.gender(i) = tags(6);
    experiments.injectionloc(i,:) = [tags{9:11}];
    experiments.injectionvol(i) = tags{5};
    experiments.sum(i) = tags{8};
    experiments.page_url(i) = tags{12};
end
fclose(f);
save(fullfile('Structures','experiments'),'experiments');