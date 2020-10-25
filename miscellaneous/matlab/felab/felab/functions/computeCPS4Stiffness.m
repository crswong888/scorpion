function [k, idx] = computeCPS4Stiffness(mesh, isActiveDof, E, nu, t)
    %// establish local system size
    isLocalDof = logical([1, 1, 0, 0, 0, 0]); 
    num_eqns = 4 * length(isLocalDof(isLocalDof));
    
    %// establish the Gauss quadrature point (2-point rule for linear or quadratic)
    Gauss2P = 1 / sqrt(3); weight = ones(4,2); % W_i and W_j values at each QP
    gauss = Gauss2P * [-1 -1; 1 -1; 1 1; -1 1];
    
    %// compute PS QUAD4 element stiffness matrix and store the global indices
    k = zeros(num_eqns,num_eqns,length(mesh(:,1))); idx = zeros(length(mesh(:,1)),num_eqns);
    B = zeros(3,8); % initialize strain-displacement matrix, necessary zero-entries will persist 
    for e = 1:length(mesh(:,1))
        %/ construct the 4x2 array of nodal coordinates in the global system
        node(1:4,1) = mesh(e,2:3:11); node(1:4,2) = mesh(e,3:3:12);
        for qp = 1:4
            %/ evaluate the derivative of the shape functions at the QPs
            [~, dNdxi] = evaluateCPS4ShapeFun(gauss(qp,1), gauss(qp,2));
            %/ compute the QP Jacobian matrix and determinant
            dxdxi = dNdxi * node; J = det(dxdxi);
            %/ compute the derivative of the shape functions WRT to the physical coordinate system
            dNdx = linsolve(dxdxi, dNdxi); % inv(dxdxi) * dNdxi - linsolve faster & more stable
            %/ compute the strain-displacement interpolation matrix
            B(1,1:2:7) = dNdx(1,:); % strain_xx
            B(2,2:2:8) = dNdx(2,:); % strain_yy
            B(3,1:2:7) = dNdx(2,:); B(3,2:2:8) = dNdx(1,:); % 2 * strain_xy
            %/ compute the plane stress compatibility tensor
            D = computePlaneElasticity(E, nu, 'PlaneStress');
            %/ evaluate qp intergrals and accumulate element local stiffness
            JxW = J * weight(qp,1) * weight(qp,2); 
            k(:,:,e) = k(:,:,e) + JxW * transpose(B) * D * B;
        end, k(:,:,e) = t * k(:,:,e); % multiply by element thickness
        %/ determine the global stiffness indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,1:3:10));
    end
end