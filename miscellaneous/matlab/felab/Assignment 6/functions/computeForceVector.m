function F = computeForceVector(num_nodes, forces)

    %// establish system size
    num_dof = 3 ; num_eqns = num_dof * num_nodes ;
    
    %// construct the global force vector
    F = zeros(num_eqns,1) ;
    for f = 1:length(forces{:,1})
        idx = num_dof * (forces{f,2} - 1) + (1:num_dof) ;
        F(idx) = F(idx) + transpose(forces{f,3:5}) ;
    end

end