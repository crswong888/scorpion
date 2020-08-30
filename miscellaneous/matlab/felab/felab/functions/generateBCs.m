function [forces, supports] = generateBCs(nodes, force_data, support_data, tol)
    
    %// sort the nodal coordinate data in ascending x and y order
    nodes = table2array(nodes); % convert to normal array to increase search performance
    num_nodes = length(nodes(:,1));
    
    %// round the input data to the specified match tolerance
    if (nargin < 4), tol = 1e-15; end % default is approximately double precision (15 decimals)
    nodes(:,2:3) = round(nodes(:,2:3) / tol) * tol;
    force_data(:,4:5) = round(force_data(:,4:5) / tol) * tol;
    support_data(:,4:5) = round(support_data(:,4:5) / tol) * tol;
    
    %// assign forces to nodes at specified coordinates if they exist
    ID = transpose(1:length(force_data(:,1)));
    Node = zeros(length(force_data(:,1)),1); Fx = Node; Fy = Node; Mz = Node;
    for f = 1:length(force_data(:,1))
        for i = 1:num_nodes
            if (nodes(i,2:3) == force_data(f,4:5)), Node(f) = nodes(i,1); end
        end
        if (Node(f) == 0) % node doesn't exist
            x = num2str(force_data(f,4)); y = num2str(force_data(f,5));
            error(['Could not find node for force applied at (', x, ', ', y, ')'])
        end
        Fx(f) = force_data(f,1); Fy(f) = force_data(f,2); Mz(f) = force_data(f,3);
    end, forces = table(ID, Node, Fx, Fy, Mz);
    
    %// assign support restraints to nodes at specified coordinates if they exist
    ID = transpose(1:length(support_data(:,1)));
    Node = zeros(length(support_data(:,1)),1); ux = Node; uy = Node; rz = Node;
    for s = 1:length(support_data(:,1))
        for i = 1:num_nodes
            if (nodes(i,2:3) == support_data(s,4:5)), Node(s) = nodes(i,1); end
        end
        if (Node(s) == 0) % node doesn't exist
            x = num2str(support_data(s,4)); y = num2str(support_data(s,5));
            error(['Could not find node for restraint applied at (', x, ', ', y, ')'])
        end
        ux(s) = support_data(s,1); uy(s) = support_data(s,2); rz(s) = support_data(s,3);
    end, supports = table(ID, Node, ux, uy, rz);
    
end