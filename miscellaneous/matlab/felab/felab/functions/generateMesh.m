function [mesh, props] = generateMesh(node_table, elem_table, num_local_nodes)
    %%% TODO: I need a block system to handle material properties instead of storing all of that
    %%% data per element

    %// determine number of dimensions based on node input
    width = length(node_table{1,:});
    num_dims = width - 1;
    
    %// only loop over systemwide nodes that are connected to input element data
    [~, connected] = intersect(node_table{:,1}, unique(elem_table{:,2:(1 + num_local_nodes)}(:)));
    node = node_table{connected,:};
    
    %// assign element end node names to node IDs and their coordinates
    num_elems = length(elem_table{:,1});
    mesh = zeros(num_elems, width*num_local_nodes);
    for e = 1:num_elems
        for i = 1:width:(width * num_local_nodes)
            [~, local_node] = intersect(node(:,1), elem_table{e,(i-1)/width+2});
            mesh(e,i:i+num_dims) = node(local_node,:); 
        end
    end
    
    %// create element property table if specified (for example, E, A, I)
    if (length(elem_table{1,:}) > num_local_nodes + 1)
        props = zeros(num_elems,length(elem_table{1,num_local_nodes+2:end}));
        for e = 1:num_elems
            props(e,:) = elem_table{e,num_local_nodes+2:end};
        end
    else
        props = [];
    end
end