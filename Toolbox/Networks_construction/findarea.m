function findarea(area)

load('nodelist','nodelist','acros');
id = find(contains(lower(nodelist),area));
for i = 1:length(id)
    fprintf('%d\t%s\t%s\n',id(i),acros{id(i)},nodelist{id(i)});
end