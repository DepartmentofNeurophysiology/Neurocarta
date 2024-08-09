function ct = getcentrality(paths)
%% Get betweenness centrality
% For every node calculate the betweenness centrality, a measure to
% determine how important the role of a node is in the global network
% structure.
% 
% ct = get_centrality(paths)
% 
% Input:
% paths (optional): Cell array with shortest paths, obtained from getpaths(map)
% 
% Output:
% ct: array of centrality values for each node

N = size(paths, 1);
if N ~= size(paths, 2) % Bilateral map
    paths = [paths ; [paths(:,(N+1):(2*N)) paths(:,1:N)]];
    N = size(paths, 1);
end
ct = zeros(1, N);

for i = 1:N
    for j = 1:N
        ct(paths{i,j}(2:end-1)) = ct(paths{i,j}(2:end-1)) + 1;
    end
end

ct = ct / N^2; % Normalize
