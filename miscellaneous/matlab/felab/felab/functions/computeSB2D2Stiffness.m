function [k, idx] = computeSB2D2Stiffness(mesh, props, isActiveDof)    
    %// establish local system size
    isLocalDof = logical([1, 1, 0, 0, 0, 1]);
    num_eqns = 2 * length(isLocalDof(isLocalDof));
    
    %// establish Gauss quadrature point rules
    [xi1, W1] = gaussRules(1);
    [xi2, W2] = gaussRules(2);
    [xi3, W3] = gaussRules(3);
    
    %// compute beam element stiffness matrix and store the global indices
    k = zeros(num_eqns, num_eqns, length(mesh(:,1))); idx = zeros(length(mesh(:,1)), num_eqns);
    comp = [1, 4]; vcomp = [2, 3, 5, 6];
    for e = 1:length(mesh(:,1))
        %/ define convenience variables        
        G = props(e,1) / (2 + 2 * props(e,2));
        EA = props(e,1) * props(e,3);
        kappaGA = props(e,5) * G * props(e,3);
        EI = props(e,1) * props(e,4);
        Omega = EI / kappaGA;
        
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
        
        kv = zeros(4,4);
        for qp = 1:3
            [~, dN] = evaluateLagrangeShapeFun(xi3(qp));
            J = dN * x;
            
            [~, dHv] = evaluateIIEShapeFun(xi3(qp), Omega, J, 'uz');
            Homega = evaluateIIEShapeFun(xi3(qp), Omega, J, 'ry');
            kv = kv + W3(qp) * transpose(dHv + J * Homega) * (dHv / J + Homega);
        end
        k(vcomp,vcomp,e) = kappaGA * kv;
        
        kv = zeros(4, 4);
        for qp = 1:2
            [~, dN] = evaluateLagrangeShapeFun(xi2(qp));
            J = dN * x;
            
            [~, dHomega] = evaluateIIEShapeFun(xi2(qp), Omega, J, 'ry');
            kv = kv + W2(qp) / J * transpose(dHomega) * dHomega;
        end
        k(vcomp,vcomp,e) = k(vcomp,vcomp,e) + EI * kv;
        
        k(:,:,e) = transpose(L) * k(:,:,e) * L;
        
        %/ determine the global stiffness indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,[1, 4]));
    end
end