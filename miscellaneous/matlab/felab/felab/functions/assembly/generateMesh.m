%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [mesh] = generateMesh(node_table, elem_table)
    %// convenience variables
    num_dims = length(node_table{1,2:end});
    num_local_nodes = length(elem_table{1,2:end});
    
    %// only loop over systemwide nodes that are connected to input element data
    [~, connected] = intersect(node_table{:,1}, unique(elem_table{:,2:(1 + num_local_nodes)}(:)));
    node = node_table{connected,:};
    
    %// generate FE mesh data
    num_elems = length(elem_table{:,1});
    mesh = zeros(num_elems, (num_dims + 1) * num_local_nodes);
    for e = 1:num_elems
        %/ get global indices of element nodes
        [~, idx] = intersect(node(:,1), elem_table{e,2:(1 + num_local_nodes)});
        local_node = node(idx,:);
        
        %/ sort 2D and 3D element node IDs counterclockwise to avoid computing negative Jacobians
        if (num_local_nodes > 2)
            % shift first node to coordinate origin and all others with it 
            for s = 2:(1 + num_dims)
                local_node(:,s) = local_node(:,s) - local_node(1,s);
            end
            
            % convert to polar or cylindicral coords and sort based on angle or height then angle
            if (num_dims == 2)
                local_node(:,(end + 1)) = cart2pol(local_node(:,2), local_node(:,3));
                local_node = sortrows(local_node, num_dims + 2);
            else
                [local_node(:,(end + 1)), ~, local_node(:,(end + 1))] = cart2pol(...
                    local_node(:,2), local_node(:,3), local_node(:,4));
                local_node = sortrows(local_node, num_dims + [3, 2]);
            end
            
            % revert local nodes back to their original positions
            local_node = node(local_node(:,1),:);
        end
        
        %/ write local node IDs and coordinate data to current element
        local_node = transpose(local_node);
        mesh(e,:) = transpose(local_node(:));
    end
end