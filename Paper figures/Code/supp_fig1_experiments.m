function supp_fig1_experiments(save)
%% Supplemental Figure 1: Auto- and cross-correlation figures

if nargin == 0
    save = "";
end

autocorrelatemap('100140949');
if save
    get_save_figure(gcf, 'Figures', 'supp_fig1_auto');
end

crosscorrelatemaps('100140756', '100140949');
if save
    get_save_figure(gcf, 'Figures', 'supp_fig1_cross');
end