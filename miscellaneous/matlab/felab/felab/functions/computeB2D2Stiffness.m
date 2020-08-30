function [k, idx] = computeB2D2Stiffness(mesh, props, isActiveDof)
    
    %// establish local system size
    isLocalDof = logical([ 1, 1, 0, 0, 0, 1 ]) ; 
    num_eqns = 2 * length(isLocalDof(isLocalDof)) ;

    %// establish the Gauss quadrature point (2-point rule for linear or quadratic)
    gauss(1) = -1 / sqrt(3) ; gauss(2) = -gauss(1) ; weight = ones(1,2) ; % W_i at each QP
    
    %// compute the beam element stiffness matrix and store the global indices
    k = zeros(num_eqns,num_eqns,length(mesh(:,1))) ; idx = zeros(length(mesh(:,1)),num_eqns) ;
    for e = 1:length(mesh(:,1))     
        %/ compute Cartesian coordinate configuration Euler transformation matrix
        dx = mesh(e,5) - mesh(e,2) ; dy = mesh(e,6) - mesh(e,3) ; ell = sqrt(dx * dx + dy * dy) ;
        %/ compute the Euler transformation matrix
        m = dx / ell ; n = dy / ell ; Phi = [ m, n, 0, 0 ; 0, 0, m, n ] ;
        for qp = 1:2
            %/ evaluate the second derivative of the shape functions at the QPs
            [~, dN, ~, d2H] = evaluateB2D2ShapeFun(gauss(qp)) ;
            %/ compute the QP Jacobian
            J = dN * Phi * [ mesh(e,2) ; mesh(e,3) ; mesh(e,5) ; mesh(e,6) ] ;
            %/ compute the element B (uniaxial) and L (bending) stress-strain interpolation matrices
            B = 1 / J * [ dN(1), 0, 0, dN(2), 0, 0 ] ;
            L = 1 / (J * J) * [ 0, d2H(1), d2H(2) * J, 0, d2H(3), d2H(4) * J ] ;
            %/ evaluate qp intergrals and accumulate element local stiffness
            JxW = J * weight(qp) ;
            k(:,:,e) = k(:,:,e) + JxW * ...
                       (props(e,2) * transpose(B) * B + props(e,3) * transpose(L) * L) ;
        end, k(:,:,e) = props(e,1) * k(:,:,e) ; % multiply by isotopic elasticity
        %/ determine the global stiffness indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,1:3:4)) ;
    end

end