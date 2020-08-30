%%% THIS WAS A POTENTIALLY USEFUL SEARCH ALGORITHM APPROACH FOR WHEN
%%% DEALING WITH MANY NODES AND MANY BC COORDINATE TO MATCH, BUT CURRENTLY
%%% HAS CERTAIN SHORTCOMINGS THAT RENDER IT USELESS FOR GENERAL PURPOSES

%%% NOTE, THE ALGORITHM DOES RESULT IN A SLIGHT PERFORMANCE INCREASE OVER
%%% CHECKING EACH BC AGAINST EACH NODE, JUST NEED TO GET THIS FUNCTION IN
%%% PROPER WORKING ORDER

function [forces, supports] = generateBCsSearchAlgorithm(nodes, force_data, restraint_data, tol)

    %%% node = node coordinate table
    %%% force_data = [force_1, force_2, force_3, x, y]
    %%% restraint_data = [restrain_1, restrain_2, restraint_3, x, y]
    
    %// sort the nodal coordinate data in ascending x and y order
    nodes = sortrows(sortrows(nodes, 3), 2); % sort first by y and then by x
    nodes = table2array(nodes); % conver to normal array to increase search performance
    num_nodes = length(nodes(:,1));
    
    %// round the input data to the specified match tolerance
    if (nargin < 4), tol = 1e-15; end % default is approximately double precision
    nodes(:,2:3) = round(nodes(:,2:3) / tol) * tol;
    force_data(:,4:5) = round(force_data(:,4:5) / tol) * tol;
    restraint_data(:,4:5) = round(restraint_data(:,4:5) / tol) * tol;
    
    %// assign forces to nodes at specified coordinates if they exist
    ID = transpose(1:length(force_data(:,1)));
    Node = zeros(length(force_data(:,1)),1); force_x = Node; force_y = Node; moment_z = Node;
    for f = 1:length(force_data(:,1))
        inc = ceil(num_nodes / 10) - 1; i = 1;
        while (i <= num_nodes - inc)
            if (nodes(i+inc,2) < force_data(f,4))
                i = i + inc;
            elseif (nodes(i,2) == force_data(f,4)) % found a nodal x match -> begin searching y
                if ((nodes(i+inc,3) < force_data(f,5)) && (nodes(i+inc,2) == force_data(f,4)))
                    i = i + inc; % the second check is to ensure we dont increment to next x set
                elseif (nodes(i,3) > force_data(f,5)) % its possible that we overshot the target
                    inc = ceil(inc / 5); % but it couldn't have been overshot by much, so refine
                    i = i - inc; 
                elseif (nodes(i,2:3) == force_data(f,4:5))
                    Node(f) = nodes(i,1); break
                elseif (i < inc) % if were searching y only in first x set, index 1 at a time
                    i = i + 1;
                else
                    inc = ceil(inc / 5); i = i + inc;
                end
            else
                inc = ceil(inc / 5); i = i + inc;
            end
        end
        if (Node(f) == 0)
            if (nodes(i,2:3) == force_data(f,4:5)) % if matching node index is very last one
                Node(f) = nodes(i,1);
            else % node doesn't exist
                x = num2str(force_data(f,4)); y = num2str(force_data(f,5));
                error(['Could not find node for force applied at (', x, ', ', y, ')'])
            end
        end
        force_x(f) = force_data(f,1);
        force_y(f) = force_data(f,2);
        moment_z(f) = force_data(f,3);
    end, forces = table(ID, Node, force_x, force_y, moment_z);
    
    %// assign support restraints to nodes at specified coordinates if they exist
    ID = transpose(1:length(restraint_data(:,1)));
    Node = zeros(length(restraint_data(:,1)),1); ux = Node; uy = Node; rz = Node;
    for s = 1:length(restraint_data(:,1))
        inc = ceil(num_nodes / 10) - 1; i = 1;
        while (i <= num_nodes - inc)
            if (nodes(i+inc,2) < restraint_data(s,4))
                i = i + inc;
            elseif (nodes(i,2) == restraint_data(s,4)) % found a nodal x match -> begin searching y
                if ((nodes(i+inc,3) < restraint_data(s,5)) && (nodes(i+inc,2) == restraint_data(s,4)))
                    i = i + inc; % the second check is to ensure we dont increment to next x set
                elseif (nodes(i,3) > restraint_data(s,5)) % its possible that we overshot the target
                    inc = ceil(inc / 5); % but it couldn't have been overshot by much, so refine
                    i = i - inc; 
                elseif (nodes(i,2:3) == restraint_data(s,4:5))
                    Node(s) = nodes(i,1); break
                elseif (i < inc) % if were searching y only in first x set, index 1 at a time
                    i = i + 1;
                else
                    inc = ceil(inc / 5); i = i + inc;
                end
            else
                inc = ceil(inc / 5); i = i + inc;
            end
        end
        if (Node(s) == 0)
            if (nodes(i,2:3) == restraint_data(s,4:5)) % if matching node index is very last one
                Node(s) = nodes(i,1);
            else % node doesn't exist
                x = num2str(restraint_data(s,4)); y = num2str(restraint_data(s,5));
                error(['Could not find node for restraint applied at (', x, ', ', y, ')'])
            end
        end
        ux(s) = restraint_data(s,1);
        uy(s) = restraint_data(s,2);
        rz(s) = restraint_data(s,3);
    end, supports = table(ID, Node, ux, uy, rz);
    
end