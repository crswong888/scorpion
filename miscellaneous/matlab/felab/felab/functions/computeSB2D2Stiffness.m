function [k, idx] = computeSB2D2Stiffness(mesh, props, isActiveDof)    
    %// establish local system size
    isLocalDof = logical([1, 1, 0, 0, 0, 1]);
    num_eqns = 2 * length(isLocalDof(isLocalDof));
    
    %// establish Gauss quadrature rules
    [xi1, W1] = gaussRules(1);
    [xi2, W2] = gaussRules(2);
    [xi3, W3] = gaussRules(3);
    
    %// store dof indices for individual stress divergence components
    comp = [1, 4]; % uniaxial 
    vcomp = [2, 3, 5, 6]; % transverse deflection along y and bending about z
    
    %// compute beam element stiffness matrix and store its system indices
    k = zeros(num_eqns, num_eqns, length(mesh(:,1))); 
    idx = zeros(length(mesh(:,1)), num_eqns);
    for e = 1:length(mesh(:,1))
        %/ define convenience variables for geo/mat props        
        G = props(e,1) / (2 + 2 * props(e,2));
        EA = props(e,1) * props(e,3);
        kappaGA = props(e,5) * G * props(e,3);
        EI = props(e,1) * props(e,4);
        Omega = EI / kappaGA;
        
        %/ compute unit normal of beam longitudinal axis
        nx = (mesh(e,5:6) - mesh(e,2:3)) / norm(mesh(e,5:6) - mesh(e,2:3));
        
        %/ get nodal coordinates in natural system
        x = [nx, zeros(1,2); zeros(1,2), nx] * transpose([mesh(e,2:3), mesh(e,5:6)]);
        
        %/ assemble Euler rotation matrix
        Phi = [nx(1), nx(2), 0; -nx(2), nx(1), 0; 0, 0, 1];
        L = [Phi, zeros(3, 3); 
             zeros(3, 3), Phi];
        
        %/ evaluate derivative of Lagrange shape functions (constant polynomial)
        [~, dN] = evaluateLagrangeShapeFun(xi1);
        
        %/ compute Jacobian (constant over element)
        J = dN * x;
        
        %/ compute axial stiffness at qp
        k(comp,comp,e) = EA * W1 / J * transpose(dN) * dN;
        
        %/ compute shear contribution to y-deflection & z-bending stiffnesses
        for qp = 1:3
            % evaluate derivative of IIE shape functions for y-deflection at qp
            [~, dHv] = evaluateInterdependentShapeFun(xi3(qp), Omega, J, 'uy');
            % evaluate IIE shape functions for z-bending at qp
            Homega = evaluateInterdependentShapeFun(xi3(qp), Omega, J, 'rz');
            % evaluate Gauss quadrature intergral and accumulate stiffness over all qps
            k(vcomp,vcomp,e) = k(vcomp,vcomp,e) + W3(qp)...
                               * transpose(dHv - J * Homega) * (dHv / J - Homega);
        end
        k(vcomp,vcomp,e) = kappaGA * k(vcomp,vcomp,e); % multiply beam props
        
        %/ compute curvature contribution to y-deflection & z-bending stiffnesses
        kv = zeros(4, 4); % allocate a temporary space to store contributions
        for qp = 1:2
            % evaluate derivative of IIE shape functions for z-bending at qp
            [~, dHomega] = evaluateInterdependentShapeFun(xi2(qp), Omega, J, 'rz');
            % evaluate Gauss quadrature intergral and accumulate stiffness over all qps
            kv = kv + W2(qp) / J * transpose(dHomega) * dHomega;
        end
        k(vcomp,vcomp,e) = k(vcomp,vcomp,e) + EI * kv; % multiply beam props and add contribution
        
        %/ rotate dofs into global coordinate system
        k(:,:,e) = transpose(L) * k(:,:,e) * L;
        
        %/ determine system indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,[1, 4]));
    end
end