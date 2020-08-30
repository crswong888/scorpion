function [k, idx] = computeC3D8Stiffness(mesh, props, isActiveDof)

    %// establish local system size
    isLocalDof = logical([1, 1, 1, 0, 0, 0]); 
    num_eqns = 8 * length(isLocalDof(isLocalDof));
    
    %// establish the Gauss quadrature point (2-point rule for linear or quadratic)
    Gauss2P = 1 / sqrt(3); weight = ones(8,3); % W_i, W_j, and W_k values at each QP
    gauss = Gauss2P * ...
            [-1 -1 -1; 1 -1 -1; 1 1 -1; -1 1 -1; -1 -1 1; 1 -1 1; 1 1 1; -1 1 1];
    
    %// compute C3D8 element stiffness matrix with isotropic elasticity and store the global indices
    k = zeros(num_eqns,num_eqns,length(mesh(:,1))); idx = zeros(length(mesh(:,1)),num_eqns);
    B = zeros(6,24); % initialize strain-displacement matrix, necessary zero-entries will persist 
    for e = 1:length(mesh(:,1))
        %/ construct the 8x3 array of nodal coordinates in the global system
        node(1:8,1) = mesh(e,2:4:30); node(1:8,2) = mesh(e,3:4:31); node(1:8,3) = mesh(e,4:4:32);
        for qp = 1:8
            %/ evaluate the derivative of the shape functions at the QPs
            [~, dNdxi] = evaluateC3D8ShapeFun(gauss(qp,1), gauss(qp,2), gauss(qp,3));
            %/ compute the QP Jacobian matrix and determinant
            dxdxi = dNdxi * node; J = det(dxdxi);
            %/ compute the derivative of the shape functions WRT to the physical coordinate system
            dNdx = linsolve(dxdxi, dNdxi); % inv(dxdxi) * dNdxi - linsolve faster & more stable
            %/ compute the strain-displacement interpolation matrix
            B(1,1:3:22) = dNdx(1,:); % strain_xx
            B(2,2:3:23) = dNdx(2,:); % strain_yy
            B(3,3:3:24) = dNdx(3,:); % strain_zz
            B(4,1:3:22) = dNdx(2,:); B(4,2:3:23) = dNdx(1,:); % 2 * strain_xy
            B(5,2:3:23) = dNdx(3,:); B(5,3:3:24) = dNdx(2,:); % 2 * strain_yz
            B(6,1:3:22) = dNdx(3,:); B(6,3:3:24) = dNdx(1,:); % 2 * strain_zx
            %/ compute the isotropic elasticity compatibility tensor
            D = computeIsotropicElasticity(props(e,1), props(e,2));
            %/ evaluate qp intergrals and accumulate element local stiffness
            JxW = J * weight(qp,1) * weight(qp,2) * weight(qp,3);
            k(:,:,e) = k(:,:,e) + JxW * transpose(B) * D * B;
        end
        %/ determine the global stiffness indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,1:4:29));
    end
    
end