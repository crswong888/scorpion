function idx = getGlobalDofIndex(isLocalDof, isActiveDof, nodes)
    %// establish global system size
    isLocalDof = isLocalDof(isActiveDof); % local dofs need only correspond to active globals
    num_dof = length(isActiveDof(isActiveDof));
    
    %// get the global dof index for only the element's active local dofs
    idx = []; i = 1; % initialize
    while (i <= length(nodes))
        node_idx = num_dof * (nodes(i) - 1) + (1:num_dof); % individual node's global dof indicess
        idx = cat(2, idx, node_idx(isLocalDof)); i = i + 1;
    end

end