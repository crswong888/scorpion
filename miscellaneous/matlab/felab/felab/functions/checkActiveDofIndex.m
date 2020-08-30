function [num_eqns, real_idx_diff] = checkActiveDofIndex(num_dofs, num_nodes, idx)

    %// establish the nominal size of the system of equations
    num_eqns = num_dofs * num_nodes;
    
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