function startinfo(h,data)
% autocorrelatemap() and crosscorrelatemaps() depend on this function.

set(h,'Visible','off');
subplot(h);
cla;
inj = data.inj;

if length(inj)==1
    str = sprintf('Experiment:\n%s\n',data.exp_id);
else
    str = sprintf('Experiments:\n%s\n%s\n',data.exp_id{:});
end
str = [str sprintf('Total # of Targets: %d\n',length(data.name))];
if length(inj)==1
    str = [str sprintf('Injection site:\n%s (%s)\n',data.name{inj},data.acro{inj})];
    %str = [str sprintf('Transgenic line:\n%s',data.label{1})];
else
    str = [str sprintf('Injection sites: \n1. %s (%s)\n2. %s (%s)\n',...
        data.name{inj(1)},data.acro{inj(1)},data.name{inj(2)},data.acro{inj(2)})];
    str = [str sprintf('Labels:\n1. %s\n2. %s',data.label{:})];
end
text(0.1,1,str,'VerticalAlignment','top','FontName','FixedWidth','FontSize',8);