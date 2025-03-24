function supp_fig4_region_dos(folder, save)
%% Supplemental figure 4: DOS region diagonal graphs (right side)

%% Load
if nargin == 0
    folder = 'All';
end

load('structures', 'structures', 'regions');
load(fullfile(folder, 'data'), 'dos', 'mode', 'thresholds', 'nodelist');
N = size(dos.density{1}, 1);
NR = length(regions.name);
[~, index] = ismember(nodelist, structures.name);
reg = structures.region(index);
thr = 1:5:20; % 0, 0.25, 0.5, 0.75

f = get_save_figure();

%% Calculate matrices
for m = 1:3
    include.(mode{m}) = cell(4, 1);
    regdos.(mode{m}) = cell(4, 1);
    for t = 1:4
        d = dos.(mode{m}){thr(t)};
        include.(mode{m}){thr(t)} = false(N, 1);
        for i = 1:N
            i1 = sum(isinf(d(i,:))) < N-1;
            i2 = sum(isinf(d(:,i))) < N-1;
            include.(mode{m}){thr(t)}(i) = i1 & i2;
        end
    
        ipsi = dos.(mode{m}){thr(t)}(:, 1:N);
        contra = dos.(mode{m}){thr(t)}(:, N+1:end);
        incl = include.(mode{m}){thr(t)};
        regdos.(mode{m}){t} = cell(NR, 2*NR);
        for i = 1:NR
            for j = 1:NR
                regdos.(mode{m}){t}{i, j} = ipsi(incl & reg==i, incl & reg==j);
                regdos.(mode{m}){t}{i, j+NR} = contra(incl & reg==i, incl & reg==j);
            end
        end
    end
end

%% Diagonal plots
minlim = inf;
maxlim = -inf;
for m = 1:3
    for t = 1:4
        avgdos = zeros(1, 2*NR-1);
        stddos = zeros(1, 2*NR-1);
        for i = 1:NR
            diag1 = [];
            diag2 = [];
            ix1 = NR+1-i : NR+1 : NR*NR;
            ix2 = NR*(NR-1)+i : -NR-1 : 1;
            for j = 1:i
                diag1 = [diag1 ; regdos.(mode{m}){t}{ix1(j)}(:)];
                diag2 = [diag2 ; regdos.(mode{m}){t}{ix2(j)}(:)];
            end
            avgdos(i) = mean(diag1);
            stddos(i) = std(diag1);
            if i < NR
                avgdos(2*NR-i) = mean(diag2);
                stddos(2*NR-i) = std(diag2);
            end
        end
        minlim = min(minlim, min(avgdos-stddos));
        maxlim = max(maxlim, max(avgdos+stddos));

        subplot(3, 4, (m-1)*4+t); hold on;
        fill([1:2*NR-1 2*NR-1:-1:1], [avgdos-stddos fliplr(avgdos+stddos)], [0 0 1], ...
            'FaceAlpha', 0.25, 'EdgeColor', 'none');
        axis tight; xlabel('Diagonal'); ylabel('Mean \pm St.Dev. DOS');
        title('Average DOS per region diagonal');
        set(gca, 'Color', 'none', 'XTickLabels', [string(1:NR-1) "Autoconnections" string(NR+1:2*NR-1)]);
        plot(avgdos);
    end
end

% Unify axes accross modes
for m = 1:3
    for t = 1:4
        subplot(3, 4, (m-1)*4+t);
        ylim([minlim maxlim]);
    end
end

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end