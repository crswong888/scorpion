function [mesh, props] = generateMesh(node_table, elem_table, num_dims, num_local_nodes)

    num_nodes = length(node_table{:,1}) ;
    num_elems = length(elem_table{:,1}) ;
    width = num_dims + 1 ; % column width of nodal data array
    
    %// sort the nodes indices and copy the coordinates
    node = zeros(num_nodes,width) ;
    for i = 1:num_nodes
        idx = node_table{i,1} ;
        node(idx,:) = node_table{i,1:width} ;
    end
    
    %// assign element end node names to node IDs and their coordinates
    %/ mesh = 1, x1, y1, 2, x2, y2, ..., N, xN, yN
    mesh = zeros(num_elems,width*num_local_nodes) ;
    for e = 1:num_elems
        idx = elem_table{e,1} ;
        for i = 1:width:(width * num_local_nodes)
            mesh(idx,i:i+num_dims) = node(elem_table{e,(i-1)/width+2},1:width) ; 
        end
    end
    
    %// create element property table if specified
    %/ example, for beams: props = E, A, I
    if (length(elem_table{1,:}) > num_local_nodes + 1)
        props = zeros(num_elems,length(elem_table{1,num_local_nodes+2:end})) ;
        for e = 1:num_elems
            idx = elem_table{e,1} ;
            props(idx,:) = elem_table{e,num_local_nodes+2:end} ;
        end
    else
        props = [] ;
    end

end