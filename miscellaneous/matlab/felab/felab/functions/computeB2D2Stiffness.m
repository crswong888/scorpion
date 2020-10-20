function [k, idx] = computeB2D2Stiffness(mesh, props, isActiveDof)
    %// establish local system size
    isLocalDof = logical([1, 1, 0, 0, 0, 1]);
    num_eqns = 2 * length(isLocalDof(isLocalDof));

    %// establish the Gauss quadrature point (2-point rule for linear or quadratic)
    [xi1, W1] = gaussRules(1);
    [xi2, W2] = gaussRules(2);
    
    %// compute the beam element stiffness matrix and store the global indices
    k = zeros(num_eqns,num_eqns,length(mesh(:,1))); idx = zeros(length(mesh(:,1)),num_eqns);
    comp = [1, 4]; vcomp = [2, 3, 5, 6];
    for e = 1:length(mesh(:,1))
        %/ define convenience variables        
        EA = props(e,1) * props(e,2);
        EI = props(e,1) * props(e,3);
        
        %/ compute unit normal of beam longitudinal axis
        nx = (mesh(e,5:6) - mesh(e,2:3)) / norm(mesh(e,5:6) - mesh(e,2:3));
        
        %/ get nodal coordinates in natural system
        x = [nx, zeros(1,2); zeros(1,2), nx] * transpose([mesh(e,2:3), mesh(e,5:6)]);
        
        %/ set Euler rotation matrix
        Phi = [nx(1), nx(2), 0; -nx(2), nx(1), 0; 0, 0, 1];
        L = [Phi, zeros(3, 3); 
             zeros(3, 3), Phi];
         
        [~, dN] = evaluateLagrangeShapeFun(xi1);
        J = dN * x;
        k(comp,comp,e) = EA * W1 / J * transpose(dN) * dN;
        
        for qp = 1:2
            %/ evaluate second derivative of shape functions at qp
            [~, dN, ~, d2H] = evaluateB2D2ShapeFun(xi2(qp));
            %/ compute qp Jacobian
            J = dN * x;
            %/ compute qp strain-displacement interpolation matrix
            B = 1 / (J * J) * [d2H(1), d2H(2) * J, d2H(3), d2H(4) * J];
            %/ evaluate qp intergrals and accumulate element local stiffness
            k(vcomp,vcomp,e) = k(vcomp,vcomp,e) + W2(qp) * J * transpose(B) * B;
        end
        k(vcomp,vcomp,e) = EI * k(vcomp,vcomp,e); % multiply by isotropic elasticity
        
        %/ rotate dofs into global coordinate system
        k(:,:,e) = transpose(L) * k(:,:,e) * L;
        
        %/ determine the global stiffness indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,1:3:4));
    end
end