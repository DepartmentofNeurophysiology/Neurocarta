function fig4_dos(folder, save)
%% Figure 4: DOS as a function of threshold for different modes
% Subplots/information:
% - DOS matrices for different modes and thresholds (e.g. 3x4 matrices)
% - Sorted plots of DOS per node for all 20 thresholds

%% Load and normalize
if nargin == 0
    folder = 'All';
end

load('structures', 'structures', 'regions');
load(fullfile(folder, 'data'), 'dos', 'thresholds', 'mode', 'nodelist');
N = size(dos.density{1}, 1);

f = get_save_figure();
thr = 1:5:20; % 0, 0.25, 0.5, 0.75
reg_thr = 16; % 0.75

mindos = 0;
maxdos = 0;
for m = 1:3
    include.(mode{m}) = cell(length(thresholds), 1);
    for t = 1:length(thresholds)
        d = dos.(mode{m}){t};
        include.(mode{m}){t} = false(N, 1);
        for i = 1:N
            i1 = sum(isinf(d(i,:))) < N-1;
            i2 = sum(isinf(d(:,i))) < N-1;
            include.(mode{m}){t}(i) = i1 & i2;
        end
        % Calculate maximum DOS in the 9 displayed matrices, for caxis
        if ismember(t, thr)
            mindos = min(mindos, min(d(~isinf(d))));
            maxdos = max(maxdos, max(d(~isinf(d))));
        end
    end
end
cm = get_cmap([mindos maxdos], true);

%% DOS maps per mode and threshold
for m = 1:3
    for t = 1:3
        subplot(3, 10, [(m-1)*10+t*2-1 (m-1)*10+t*2]);
        i = include.(mode{m}){t+1};
        imagesc(dos.(mode{m}){thr(t+1)}(i,[i i])); axis equal tight; colormap(gca, cm.cm);
        set(gca, 'XTick', [], 'YTick', []);
        caxis(cm.lims);
        if t == 1
            ylabel('Sources');
        end
        colorbar('southoutside', 'TickLength', 0, 'Ticks', cm.ticks, ...
            'TickLabels', cm.ticklabels);
        title(sprintf('%s > %.2f', [upper(mode{m}(1)) mode{m}(2:end)], thresholds(thr(t+1))/100));
        %{
        if t == 1 && m == 1
            title(sprintf('%s > %.2f', mode{m}, thresholds(thr(t+1))/100));
        elseif t == 1
            title(sprintf('%s', mode{m}));
        elseif m == 1
            title(sprintf('%s > %.2f', thresholds(thr(t+1))/100));
        end
        %}
        if m == 3
            xlabel('ipsilateral \leftarrow Targets \rightarrow contralateral');
        end
    end
end

%% Sorted avg DOS per node per mode and threshold
for m = 1:3
    subplot(3, 10, (m-1)*10+7);
    hold on; set(gca,'Color','none', 'YGrid', 'on');
    mx = 0;
    for t = 1:length(thresholds)
        col = [t/length(thresholds) 0 0];
        i = include.(mode{m}){t};
        tmp = sort(mean(dos.(mode{m}){t}(i, [i false(size(i))]), 2), 'descend');
        mx = max([mx max(tmp)]);
        plot(tmp, 'Color', col);
    end
    xlabel('Nodes (sorted)'); ylabel('Avgerage DOS'); axis tight;
    title('Ipsilateral');
    
    subplot(3, 10, (m-1)*10+8);
    hold on; set(gca,'Color','none', 'YGrid', 'on');
    for t = 1:length(thresholds)
        col = [t/length(thresholds) 0 0];
        tmp = sort(mean(dos.(mode{m}){t}(i, [false(size(i)) i]), 2), 'descend');
        mx = max([mx max(tmp)]);
        plot(tmp, 'Color', col);
    end
    xlabel('Nodes (sorted)'); axis tight;
    set(gca, 'ytick', 1:ceil(mx), 'xtick', [], 'ylim', [1 ceil(mx)]);
    title('Contralateral');
    if m == 2
        legend(string(thresholds), 'Location', 'East');
    end
    subplot(3, 10, (m-1)*10+7);
    set(gca, 'ytick', 1:ceil(mx), 'xtick', [], 'ylim', [1 ceil(mx)]);
end

%% Calculate region matrices
NR = length(regions.name);
[~, index] = ismember(nodelist, structures.name);
reg = structures.region(index);

for m = 1:3
    include.(mode{m}) = include.(mode{m}){reg_thr};
    dos.(mode{m}) = dos.(mode{m}){reg_thr};
    ipsi = dos.(mode{m})(:, 1:N);
    contra = dos.(mode{m})(:, N+1:end);
    regdos.(mode{m}) = cell(NR, 2*NR);
    incl = include.(mode{m});
    for i = 1:NR
        for j = 1:NR
            regdos.(mode{m}){i, j} = ipsi(incl & reg==i, incl & reg==j);
            regdos.(mode{m}){i, j+NR} = contra(incl & reg==i, incl & reg==j);
        end
    end
end

%% Average DOS per region, all modes, 1 threshold
cm = get_cmap;
minavg = 1;
maxavg = -inf;
for m = 1:3
    avgdos.(mode{m}) = cellfun(@(x) mean(mean(x)), regdos.(mode{m}));
    minavg = min([min(avgdos.(mode{m})(:)), minavg]);
    maxavg = max([max(avgdos.(mode{m})(:)), maxavg]);
end

for m = 1:3
    subplot(3, 10, [(m-1)*10+9 m*10]);
    imagesc(avgdos.(mode{m})); axis equal tight; colormap(gca, cm.cm);
    set(gca, 'ticklength', [0 0], 'xtick', 1:2*NR, 'ytick', 1:NR, ...
        'xticklabels', [regions.acro regions.acro], 'yticklabels', [regions.acro]);
    %{
    if m == 3
        xlabel('ipsilateral \leftarrow Targets \rightarrow contralateral');
    end
    %}
    ylabel('Sources');
    title(sprintf('Average DOS, %s > 0.75', [upper(mode{m}(1)) mode{m}(2:end)]));
    caxis([minavg maxavg]);
    colorbar('Southoutside');
end

%% Save
if nargin > 1 && save
    get_save_figure(f, folder, mfilename);
end