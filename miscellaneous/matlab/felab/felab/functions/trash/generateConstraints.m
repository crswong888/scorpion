function constraints = generateConstraints(nodes, constraint_data, tol)

    %// sort the nodal coordinate data in ascending x and y order
    nodes = table2array(nodes); % convert to normal array to increase search performance
    num_nodes = length(nodes(:,1));
    
    %// round the input data to the specified match tolerance
    if (nargin < 3), tol = 1e-15; end % default is approximately double precision (15 decimals)
    nodes(:,2:3) = round(nodes(:,2:3) / tol) * tol;
    constraint_data = round(constraint_data / tol) * tol;
    
    %// assign constraints to master and slave nodes at specified coordinates if they exist
    ID = transpose(1:length(constraint_data(:,1)));
    master = zeros(length(constraint_data(:,1)),1); slave = master;
    for c = 1:length(constraint_data(:,1))
        for i = 1:num_nodes
            if (nodes(i,2:3) == constraint_data(c,1:2)) 
                master(c) = nodes(i,1);
            elseif (nodes(i,2:3) == constraint_data(c,3:4))
                slave(c) = nodes(i,1);
            end
        end
        if (master(c) == 0) % master node doesn't exist
            x = num2str(constraint_data(c,1)); y = num2str(constraint_data(c,2));
            error(['Could not find master node at (', x, ', ', y, ') for constraint ', num2str(c)])
        elseif (slave(c) == 0) % slave node doesn't exist
            x = num2str(constraint_data(c,3)); y = num2str(constraint_data(c,4));
            error(['Could not find slave node at (', x, ', ', y, ') for constraint ', num2str(c)])
        end
    end, constraints = table(ID, master, slave);

end