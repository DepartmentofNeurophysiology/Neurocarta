function generatemaps(outfile,thr)
% This function constructs multiple networks with varying parameters. For
% each projection type, an adjacency matrix is created with. For various
% threshold values, distance matrices are computed from this matrix.
% 
% generatemaps(outfile, [thr])
% 
% Input:
% outfile: filename for storing generated networks
% thr (optional): vector with values from 0-100 indicating the threshold
% for each map. This can be used to create multiple maps with increasing
% thresholds in order to compare for example the degree of separation in
% different maps. Default: thr = 0:5:95.

varnames = {'density','energy','intensity','volume'};
if nargin==1
    thr = 0:5:95;
end

for i = 1:4
    b = loadmap(varnames{i}); % Bilateral map
    n = size(b,1);
    ip = b(:,1:n); % Unilateral map
    for j = 1:length(thr)
        % Create filtered maps
        ipsi.(varnames{i}).map{j,1} = filtermap(ip,thr(j));
        bi.(varnames{i}).map{j,1} = filtermap(b,thr(j));
        % Create Degree of Separation matrices
        ipsi.(varnames{i}).dos{j,1} = getsynapses(ip);
        bi.(varnames{i}).dos{j,1} = getsynapses(b);
        %[d,p] = getpaths(ipsi.map{j},K);
        %ipsi.pathlength{j,1} = d;
        %ipsi.paths{j,1} = p;
        %[d,p] = getpaths(bi.map{j},K);
        %bi.pathlength{j,1} = d;
        %bi.paths{j,1} = p;
        fprintf('Map: %s (%d/4), Thr: %d/%d\n',varnames{i},i,j,length(thr));
    end
    save(outfile,'ipsi','bi','thr');
end
