function [num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, idx)
    %// this assumes that input is a cell array of element blocks - convert to cell if not
    if (~iscell(idx))
        idx = {idx};
    end

    %// establish nominal size of the system of equations
    nodes = table2array(nodes);
    num_eqns = num_dofs * length(nodes(:,1));

    %// search for duplicate node IDs
    duplicates = [];
    for i = 1:(length(nodes(:,1)) - 1)        
        isduplicate = (any(nodes(i,1) == nodes([1:(i - 1), (i + 1):end],1)));
        if ((isduplicate) && (~ismember(nodes(i,1), duplicates)))
            duplicates = cat(2, duplicates, nodes(i,1));
        end
    end
    
    %/ assert no duplicates
    if (~isempty(duplicates))
        error(['Node IDs must be strictly unique. Duplicate IDs found: ', num2str(duplicates), '.'])
    end
    
    %// assert succesive integer IDs
    for i = 1:(length(nodes(:,1)) - 1)
        if (nodes((i + 1),1) ~= i + 1)
            error(['Node IDs must be ordered as succesive integer values starting at 1 in ',...
                   'order for the system of equations to be assembled properly. There may be ',...
                   'no gaps. Consider using consolidateNodeIDs().'])
        end
    end
    
    %// loop over element blocks & find active dofs, i.e., find equations w/ stiffness contributions
    isActive = false(num_eqns,1); % assume all inactive until a matching nominal index is found
    for block = 1:length(idx)
        for e = 1:length(idx{block}(:,1))
            isActive(idx{block}(e,:)) = true;
        end
    end
    
    %// update system size to reflect number of real equations
    num_eqns = length(isActive(isActive));
    
    %// nominal indices must be shifted by number of inactive dofs below it - compute shift amount 
    real_idx_diff = zeros(length(isActive),1);
    for dof = 1:length(isActive)
        if (~isActive(dof)), real_idx_diff(dof:end) = real_idx_diff(dof:end) + 1; end 
    end
end