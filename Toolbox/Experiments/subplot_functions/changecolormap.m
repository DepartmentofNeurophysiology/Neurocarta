function changecolormap(obj,~,node,data)
% autocorrelatemap() and crosscorrelatemaps() depend on this function.

n = length(obj.Colormap(:,1))-1;

for i = 1:length(node)
    node(i).FaceColor = repmat(obj.Colormap(floor(data.color(node(i).UserData)*n)+1,:),3);
end