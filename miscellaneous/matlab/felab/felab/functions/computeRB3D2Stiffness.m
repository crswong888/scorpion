function [k, idx] = computeRB3D2Stiffness(constraints, nodes, C, is_active_dof)

    %// establish system size
    is_local_dof = logical([ 1, 1, 1, 1, 1, 1 ]) ; 
    num_eqns = 2 * length(is_local_dof(is_local_dof)) ;
    
    %// establish the Gauss quadrature point (2-point rule for linear or quadratic)
    gauss(1) = -1 / sqrt(3) ; gauss(2) = -gauss(1) ; weight = ones(1,2) ; % W_i at each QP

end