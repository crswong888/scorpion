function [forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof, tol)
    %%% TODO: this is kind of a horrible way to do all of this - make it better
    
    %%% Ultimately, the only reason this function is useful is for the case where the mesh is huge
    %%% and someone has no idea what their BC node IDs are, but knows their coordinates
                                      
    %// sort the nodal coordinate data in ascending x and y order
    nodes = table2array(nodes); % convert to normal array to increase search performance
    num_nodes = length(nodes(:,1));
    num_dims = length(nodes(1,2:end));
    num_dofs = length(isActiveDof(isActiveDof));
    
    %// round the input data to the specified match tolerance
    if (nargin < 6), tol = 1e-15; end % default is approximately double precision (15 decimals)
    nodes(:,2:(num_dims + 1)) = round(nodes(:,2:(num_dims + 1)) / tol) * tol;
    force_data(:,(num_dofs + 1):(num_dofs + num_dims)) = round(...
        force_data(:,(num_dofs + 1):(num_dofs + num_dims)) / tol) * tol;
    support_data(:,(num_dofs + 1):(num_dofs + num_dims)) = round(...
        support_data(:,(num_dofs + 1):(num_dofs + num_dims)) / tol) * tol;
    
    %// assign forces to nodes at specified coordinates if they exist
    ID = transpose(1:length(force_data(:,1)));
    Node = zeros(length(force_data(:,1)),1);
    Fx = Node; Fy = Node; Fz = Node; Mx = Node; My = Node; Mz = Node;
    for f = 1:length(force_data(:,1))
        coords = force_data(f,(num_dofs + 1):(num_dofs + num_dims));
        for i = 1:num_nodes
            if (nodes(i,2:(num_dims + 1)) == coords) 
                Node(f) = nodes(i,1); 
            end
        end
        if (Node(f) == 0) % node doesn't exist
            error(['Could not find node for force applied at (', num2str(coords), ')'])
        end
        idx = 0;
        if (isActiveDof(1)), idx = idx + 1; Fx(f) = force_data(f,idx); end
        if (isActiveDof(2)), idx = idx + 1; Fy(f) = force_data(f,idx); end
        if (isActiveDof(3)), idx = idx + 1; Fz(f) = force_data(f,idx); end
        if (isActiveDof(4)), idx = idx + 1; Mx(f) = force_data(f,idx); end
        if (isActiveDof(5)), idx = idx + 1; My(f) = force_data(f,idx); end
        if (isActiveDof(6)), idx = idx + 1; Mz(f) = force_data(f,idx); end
    end
    forces = table(Fx, Fy, Fz, Mx, My, Mz);
    forces = cat(2, table(ID, Node), forces(:,isActiveDof));
    
    %// assign support restraints to nodes at specified coordinates if they exist
    ID = transpose(1:length(support_data(:,1)));
    Node = zeros(length(support_data(:,1)),1); 
    ux = Node; uy = Node; uz = Node; rx = Node; ry = Node; rz = Node;
    for s = 1:length(support_data(:,1))
        coords = support_data(s,(num_dofs + 1):(num_dofs + num_dims));
        for i = 1:num_nodes
            if (nodes(i,2:(num_dims + 1)) == coords) 
                Node(s) = nodes(i,1); 
            end
        end
        if (Node(s) == 0) % node doesn't exist
            error(['Could not find node for restraint applied at (', num2str(coords), ')'])
        end
        idx = 0;
        if (isActiveDof(1)), idx = idx + 1; ux(s) = support_data(s,idx); end
        if (isActiveDof(2)), idx = idx + 1; uy(s) = support_data(s,idx); end
        if (isActiveDof(3)), idx = idx + 1; uz(s) = support_data(s,idx); end
        if (isActiveDof(4)), idx = idx + 1; rx(s) = support_data(s,idx); end
        if (isActiveDof(5)), idx = idx + 1; ry(s) = support_data(s,idx); end
        if (isActiveDof(6)), idx = idx + 1; rz(s) = support_data(s,idx); end
    end
    supports = table(ux, uy, uz, rx, ry, rz);
    supports = cat(2, table(ID, Node), supports(:,isActiveDof));
end