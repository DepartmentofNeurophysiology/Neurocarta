function [d,A] = kshortestpaths(L,K,source,target,trim)
%% Calculate K shortest paths (KSPs) in a graph using Yen's algorithm.
% https://en.wikipedia.org/wiki/Yen%27s_algorithm
% 
% [d,A] = kshortestpaths(L,K,source,target)
% 
% Input:
% L: length matrix (e.g. dot inverse of adjacency matrix, uni- or
% bilateral)
% K: number of shortest paths to find
% source: source node
% target: target node
% 
% Output:
% d: array with path lengths
% A: cell array with K shortest paths

if nargin < 5
    trim = false;
end
if source == target
    A = repmat({source},1,K);
    d = zeros(1,K);
    return;
end

if size(L,1) ~= size(L,2) % Bilateral map
    n = size(L,1);
    L = [L;[L(:,(n+1):(2*n)) L(:,1:n)]];
end

A = cell(K,1);
[~,A(1,:)] = shortestpath(L,source,target); % First KSP using Dijkstra

B = []; % Potential KSPs
Bc = []; % Cost of potential KSPs
for k = 1:K-1
    for i = 1:length(A{k})-1
        L1 = L; % Copy of original length matrix
        spurNode = A{k}(i); % Set the spur node
        rootPath = A{k}(1:i); % Copy root path from previous KSP
        rootCost = getpathlength(L1,rootPath); % Cost of root path

        for j = 1:k % For all KSPs that are already found
            p = A{j};
            if length(p)>i
                if isequal(rootPath,p(1:i))
                    L1(p(i),p(i+1)) = Inf; % Remove edge from graph
                end
            end
        end

        L1(rootPath(1:end-1),:) = Inf; % Remove root path nodes from graph
        L1(:,rootPath(1:end-1)) = Inf;

        [spurCost,spurPath] = shortestpath(L1,spurNode,target);
        spurPath = spurPath{1};
%        if spurCost ~= Inf
            totalPath = [rootPath spurPath(2:end)];
            totalCost = rootCost+spurCost;
            B = [B {totalPath}];
            Bc = [Bc totalCost];
            for j = 1:length(B)-1 % Discard path if duplicate
                if isequal(B{j},totalPath)
                    B = B(1:end-1);
                    Bc = Bc(1:end-1);
                    break;
                end
            end
%        else
%            disp('inf');
%        end
    end

    [~,ksp] = min(Bc);
    if isempty(B)
        break;
    else
        A(k+1) = B(ksp);
    end
    B(ksp) = [];
    Bc(ksp) = [];
end
A = A'; % From Kx1 to 1xK matrix size
d = getpathlength(L,A);

% Filter out wrong paths (happens when K too large)
if trim
    nfound = find(diff(d)<0,1);
    if length(nfound) == 1
        d = d(1:nfound);
        A = A(1:nfound);
    end
end