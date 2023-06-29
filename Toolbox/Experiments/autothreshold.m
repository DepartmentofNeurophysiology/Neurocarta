function thr = autothreshold(exp_id,proj,zscore)
%% Filter noise from projection data
% Fits a Gaussian curve through the projection data and determine a cutoff
% point in terms of z-score. Default is -1.
% 
% thr = autothreshold(exp_id,[proj],[zscore])
% 
% Input:
% exp_id: experiment id (filename of mat file without extension) of
% experiment file that will be thresholded (and overwritten).
% proj: (optional) variable used for determining threshold in autothreshold
% function. Default is 'density'.
% threshold (optional): threshold value that is used by autothreshold
% function, default is -1.
% 
% Output:
% thr: numerical threshold value
% 
% Example: thr = autothreshold('100140756','energy',-2.5);

%% Load data
bins = 200; % the number of categories for the histogram
if nargin==1
    proj = 'density';
    zscore = -1;
end

data = load(fullfile('Data',exp_id));
values = [data.ipsi.(proj);data.contra.(proj)];

%% Calculate data distribution and threshold
[y,x] = histcounts(log10(values),bins);
x = x(1:end-1) + (x(2)-x(1))/2;

% Fit a Gaussian function through the distribution
% f contains the fitted function; f.b1=mean, f.c1=std.dev
w = true;
while w
    w = false;
    try
        f = fit(x',y','gauss1');
    catch
        y(find(y~=0,1)) = 0;
        w = true;
    end
end

% Calculate cutoff point: b1 = mean, c1 = sigma
thr = f.b1 + zscore * f.c1;