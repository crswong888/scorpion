function [k, idx] = computeSB3D2Stiffness(mesh, props, isActiveDof)    
    %// establish local system size
    isLocalDof = logical([1, 1, 1, 1, 1, 1]);
    num_eqns = 2 * length(isLocalDof(isLocalDof));
    
    %// establish Gauss quadrature point rules
    [xi1, W1] = gaussRules(1);
    [xi2, W2] = gaussRules(2);
    [xi3, W3] = gaussRules(3);
    
    %// compute beam element stiffness matrix and store the global indices
    k = zeros(num_eqns, num_eqns, length(mesh(:,1))); idx = zeros(length(mesh(:,1)), num_eqns);
    comp = [1, 7]; vcomp = [2, 6, 8, 12]; wcomp = [3, 5, 9, 11];
    for e = 1:length(mesh(:,1))
        %/ define convenience variables        
        G = props(e,1) / (2 + 2 * props(e,2));
        EA = props(e,1) * props(e,3);
        kappaGA = props(e,7) * G * props(e,3);
        kappaGJ = props(e,7) * G * props(e,6);
        EIyy = props(e,1) * props(e,4);
        EIzz = props(e,1) * props(e,5);
        Omega_yy = EIyy / kappaGA;
        Omega_zz = EIzz / kappaGA;
        
        %/ compute unit normal of beam longitudinal axis
        nx = (mesh(e,6:8) - mesh(e,2:4)) / norm(mesh(e,6:8) - mesh(e,2:4));
        
        %/ get nodal coordinates in natural system
        x = [nx, zeros(1,3); zeros(1,3), nx] * transpose([mesh(e,2:4), mesh(e,6:8)]);
        
        %/ compute a default unit normal for local y-axis or use input if provided
        if (length(props(1,:)) == 8)
            ny = props(:,8);
        else
            ny = [-nx(2), nx(1), 0]; % rotates y about z by same amount x has
        end
        
        %/ assert that y-axis is perpindicular to x (rounded to nearest 16 decimal points)
        if (round(dot(nx, ny) / 1e-16) * 1e-16 ~= 0)
            error(' ')
        end
        
        %/ compute unit normal for local z-axis
        nz = cross(nx, ny);
        
        %/ set Euler rotation matrix
        Phi = [nx; ny; nz];
        L = [Phi, zeros(3, 9); 
             zeros(3, 3), Phi, zeros(3, 6); 
             zeros(3, 6), Phi, zeros(3, 3); 
             zeros(3, 9), Phi];
        
        [~, dN] = evaluateLagrangeShapeFun(xi1);
        J = dN * x;
        ku = W1 / J * transpose(dN) * dN;
        k(comp,comp,e) = EA * ku;
        k((comp + 3),(comp + 3),e) = kappaGJ * ku;
        
        kv = zeros(4, 4); kw = zeros(4, 4);
        for qp = 1:3
            [~, dN] = evaluateLagrangeShapeFun(xi3(qp));
            J = dN * x;
            
            [~, dHv] = evaluateIIEShapeFun(xi3(qp), Omega_zz, 'uy');
            Homega = evaluateIIEShapeFun(xi3(qp), Omega_zz, 'rz');
            kv = kv + W3(qp) * transpose(dHv + J * Homega) * (dHv / J - Homega); 
            
            [~, dHw] = evaluateIIEShapeFun(xi3(qp), Omega_yy, 'uz');
            Hphi = evaluateIIEShapeFun(xi3(qp), Omega_yy, 'ry');
            kw = kw + W3(qp) * transpose(dHw + J * Hphi) * (dHw / J + Hphi);
        end
        k(vcomp,vcomp,e) = kappaGA * kv;
        k(wcomp,wcomp,e) = kappaGA * kw;
        
        %%% (NG) next lowest hanging fruit - what if c3 was negative in complementary solution?
        %%% (NG) what If I swap signs, e.g., (Homega - dHv / J), transpose(dHv - J * Homega), etc.
        %%%     -- WOAH! transpose(dHv - J * Homega) produced a symmetric matrix!!! Perhaps there is
        %%%        some way I can justify this? Note: transpose(-dHv + J * Homega) also works...
        %%%     -- Nvm, this doesn't produce the correct matrix, however, it does provide insight
        %%% we oughtta check that the complete derivation of the shape functions is good too...
        %%% (NG) new shape functions, new weak form? using new shape functions with old weak form?
        %%% (NG) what if I just use the same exact shape functions and weak form for both?
        %%%     -- the fact that even this doesn't work might suggest I have a deeper problem here.
        %%% (NG) otherwise, inspect which property kv doesn't have that kw does...
        %%%     -- they're both wrong
        %%% theres the whole issue of the shearing force being the negative tau_xy, why?
        %%% (NG) we'll need to try to develop a 2D version as a control test
        %%%     -- the 2D version of this is wrong too
        %%% (OK) what if I just direct stiffnessed it as per Reddy (in the 2D code)?
        
        kv = zeros(4, 4); kw = zeros(4, 4);
        for qp = 1:2
            [~, dN] = evaluateLagrangeShapeFun(xi2(qp));
            J = dN * x;
            
            [~, dHomega] = evaluateIIEShapeFun(xi2(qp), Omega_zz, 'rz');
            kv = kv + W2(qp) / J * transpose(dHomega) * dHomega;
            
            [~, dHphi] = evaluateIIEShapeFun(xi2(qp), Omega_yy, 'ry');
            kw = kw + W2(qp) / J * transpose(dHphi) * dHphi;
        end
        k(vcomp,vcomp,e) = k(vcomp,vcomp,e) + EIzz * kv;
        k(wcomp,wcomp,e) = k(wcomp,wcomp,e) + EIyy * kw;
        
        k(:,:,e) = transpose(L) * k(:,:,e) * L;
        
        %/ determine the global stiffness indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,[1, 5]));
    end
end