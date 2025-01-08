function exportnetwork(filename, labels, conn, directed, varargin)
%% Export network data to a file in GEXF format.
% Export a network to a GEXF (XML-like) file that can be loaded by network
% visualization software, Gephi in particular.
% 
% export_network(filename, labels, conn, directed,...)
% 
% Input:
% filename: (required) name of output file.
% labels:   (required) N-length cell array with node labels.
% conn:     (required) Connectivity matrix (N by N).
% directed: (required) true/false whether edge directionality should be
%           considered.
%
% Optionally, add properties for nodes and/or edges. For every property,
% include a parameter that is a struct with the following fields:
% % name:   Name of the property
% % data:   Values of the property for all nodes/edges. Whether the
%           property is interpreted as a node- or edge-related property
%           depends on the matrix size. If it is 'N by 1' or '1 by N', it
%           is a node property. If the size is 'N by N', it is an edge
%           propperty.
% % type:   Choose 'boolean', 'int', 'long', 'float', 'double', or 'string'
%
% To color nodes, add a node property named 'color' accompanied by a list
% of hex strings (e.g. obtained from rgb2hex()).
% 
% Limitation: node data can not be named 'id' or 'label' and edge data can
% not be named 'id', 'source', 'target' or 'weight'. Script does not check
% for this!
% 
% Example (where node_size and edge_group are extra properties):
% export_network('nw.gexf', [N*1 cell arr], [N*N arr], false, ...
%                struct('name','node_size', 'data',[N*1 arr], 'type','float'), ...
%                struct('name','edge_group', 'data',[N*N arr], 'type','boolean'))

%% Check arguments
N = size(conn, 1);
if N ~= size(conn, 2) % Bilateral map
    conn = [conn;[conn(:,(N+1):(2*N)) conn(:,1:N)]];
    N = size(conn, 1);
    labels = [labels ; strcat('c', labels)];
end

node_props = [];
edge_props = [];
node_viz = [];
edge_viz = [];
for i = 1:length(varargin)
    warning_ending=" in extra parameter " + num2str(i);
    
    for f = ["name", "data", "type"]
        assert(isfield(varargin{i}, f), f+" field missing" + warning_ending);
    end
    
    sz = size(varargin{i}.data);
    if isequal(sz, [1 N]) || isequal(sz, [N 1])
        if varargin{i}.name == "color"
            node_viz = varargin{i};
        else
            node_props = [node_props varargin{i}];
        end
    elseif isequal(sz, [N N])
        if varargin{i}.name == "color"
            edge_viz = varargin{i};
        else
            edge_props = [edge_props varargin{i}];
        end
    else
        error("Wrong size [" + num2str(sz) + "]" + warning_ending);
    end
    
    types = ["boolean","int","long","float","double","string"];
    assert(ismember(varargin{i}.type,types),"Unknown datatype "+varargin{i}.type + warning_ending);
end

%% Create XML document object
disp('Creating document...');
xmlDoc = com.mathworks.xml.XMLUtils.createDocument('gexf');
gexf = xmlDoc.getDocumentElement;
gexf.setAttribute('version', '1.3');
gexf.setAttribute('xmlns', 'http://gexf.net/1.3');
if ~(isempty(node_viz) && isempty(edge_viz))
    gexf.setAttribute('xmlns:viz', 'http://gexf.net/1.3/viz');
end

%% Create graph element
graph = xmlDoc.createElement('graph');
graph.setAttribute('mode','static');
if directed
    graph.setAttribute('defaultedgetype','directed');
else
    conn = max(conn, conn');
    conn = tril(conn);
    graph.setAttribute('defaultedgetype','undirected');
end

% Create node attribute elements
if ~isempty(node_props)
    atts = xmlDoc.createElement('attributes');
    atts.setAttribute('class','node');
    for i = 1:length(node_props)
        att = xmlDoc.createElement('attribute');
        att.setAttribute('id',num2str(i-1));
        att.setAttribute('title',node_props(i).name);
        att.setAttribute('type',node_props(i).type);
        atts.appendChild(att);
    end
    graph.appendChild(atts);
end

% Create edge attribute elements
if ~isempty(edge_props)
    atts = xmlDoc.createElement('attributes');
    atts.setAttribute('class','edge');
    for i = 1:length(edge_props)
        att = xmlDoc.createElement('attribute');
        att.setAttribute('id',num2str(i-1));
        att.setAttribute('title',edge_props(i).name);
        att.setAttribute('type',edge_props(i).type);
        atts.appendChild(att);
    end
    graph.appendChild(atts);
end
nodes = xmlDoc.createElement('nodes');
edges = xmlDoc.createElement('edges');
gexf.appendChild(graph);
graph.appendChild(nodes);
graph.appendChild(edges);

%% Add node data to graph element
disp('Writing node data to document...');
for i = 1:N
    node = xmlDoc.createElement('node');
    node.setAttribute('id',num2str(i-1));
    node.setAttribute('label',labels{i});
    if ~isempty(node_props)
        avs = xmlDoc.createElement('attvalues');
        for j = 1:length(node_props)
            av = xmlDoc.createElement('attvalue');
            av.setAttribute('for',num2str(j-1));
            if iscell(node_props(j).data(i))
                av.setAttribute('value',node_props(j).data{i});
            else
                av.setAttribute('value',num2str(node_props(j).data(i))); % num2str necessary?
            end
            avs.appendChild(av);
        end
        node.appendChild(avs);
    end
    if ~isempty(node_viz)
        viz = xmlDoc.createElement('viz:color');
        viz.setAttribute('hex', node_viz.data(i));
        node.appendChild(viz);
    end
    nodes.appendChild(node);
end

%% Add edge data to graph element
disp('Writing edge data to document...');
l = 0;
for i = 1:N
    for j = 1:N
        if conn(i,j)==0 || i == j
            continue;
        end
        edge = xmlDoc.createElement('edge');
        edge.setAttribute('id',num2str(l));
        edge.setAttribute('source',num2str(i-1));
        edge.setAttribute('target',num2str(j-1));
        edge.setAttribute('weight',num2str(conn(i,j)));
        if ~isempty(edge_props)
            avs = xmlDoc.createElement('attvalues');
            for k = 1:length(edge_props)
                av = xmlDoc.createElement('attvalue');
                av.setAttribute('for',num2str(k-1));
                if iscell(edge_props(k).data(i,j)) 
                    av.setAttribute('value',edge_props(k).data{i,j});
                else
                    av.setAttribute('value',num2str(edge_props(k).data(i,j)));
                end
                avs.appendChild(av);
            end
            edge.appendChild(avs);
        end
        if ~isempty(edge_viz)
            viz = xmlDoc.createElement('viz:color');
            viz.setAttribute('hex', edge_viz.data(i));
            edge.appendChild(viz);
        end
        edges.appendChild(edge);
        l = l+1;
    end
end

if length(filename) < 5
    filename = [filename '.gexf'];
elseif ~strcmp(filename(end-4:end),'.gexf')
    filename = [filename '.gexf'];
end
xmlwrite(filename,xmlDoc);