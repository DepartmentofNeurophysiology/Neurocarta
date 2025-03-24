function cm = get_cmap(limits, discrete)

cm.cm = flipud(colormap(gca, 'pink'));
if nargin == 0
    return;
end

mn = min(min(limits));
mx = max(max(limits));
cm.lims = [mn mx];

if mn < 0 % Bipolar
    tmp = max([abs(mn) abs(mx)]);
    mn = -tmp; mx = tmp;
    cm.lims = [mn mx];
    
    cm.cm = cm.cm(1:41,:);
    cm.cm = [repmat(linspace(0, 0.975, 40)', 1, 3) ; cm.cm];
    cm.endc = cm.cm(end, :);
    cm.startc = cm.cm(1, :);
    cm.middlec = cm.cm(ceil(size(cm.cm, 1)/2), :);
end

if nargin > 1 && discrete % Discrete
    cm.cm = cm.cm(round(linspace(1, size(cm.cm,1), 1+mx-mn)), :);
    if mn >= 0
        cm.cm = [cm.cm(end,:) ; cm.cm(1:end-1,:)];
    end
    tickdist = (mx-mn) / (1+mx-mn);
    cm.ticks = (mn+tickdist/2):tickdist:mx;
    cm.ticklabels = mn:mx;
end