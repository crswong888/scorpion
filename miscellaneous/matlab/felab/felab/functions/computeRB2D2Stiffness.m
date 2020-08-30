function [k, idx] = computeRB2D2Stiffness(constraints, nodes, C, is_active_dof)

    %// establish system size
    is_local_dof = logical([ 1, 1, 0, 0, 0, 1 ]) ; 
    num_eqns = 2 * length(is_local_dof(is_local_dof)) ;

    %// compute the rigid beam element stiffness matrix and store the global indices
    k = zeros(num_eqns,num_eqns,length(constraints{:,1})) ; 
    idx = zeros(length(constraints{:,1}),num_eqns) ;
    for c = 1:length(constraints{:,1})
        m = constraints{c,2} ; s = constraints{c,3} ; % indices of master & slave nodes
        B = [ 1, 0, nodes{m,3} - nodes{s,3}, -1,  0,  0 ;
              0, 1, nodes{s,2} - nodes{m,2},  0, -1,  0 ;
              0, 0,                       1,  0,  0, -1 ] ; % rigid strain-displacement relationship
        k(:,:,c) = C * transpose(B) * B ;
        %/ determine the global stiffness indices
        idx(c,:) = getGlobalDofIndex(is_local_dof, is_active_dof, [m, s]) ;
    end

end