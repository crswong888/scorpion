function [k, idx] = computeSB3D2Stiffness(mesh, isActiveDof, E, nu, A, Iyy, Izz, J, kappa, varargin)    
    %// parse additional arguments for element local y-axis orientation relative to second moments
    params = inputParser;
    
    %/ a valid input must be defined either once for all elements or uniquely defined per element, 
    %/ no in between. Note that if an element's unit y-norm is [0, 0, 0], then the default 
    %/ y-orientation is invoked.
    default_input = zeros(length(mesh(:,1)), 3);
    valid_input = @(x) ((isequal(size(x), size(default_input))) || (isequal(size(x), [1, 3])));
    addParameter(params, 'y_orientation', default_input, valid_input);
    parse(params, varargin{:});

    %// establish local system size
    isLocalDof = logical([1, 1, 1, 1, 1, 1]);
    num_eqns = 2 * length(isLocalDof(isLocalDof));
    
    %// establish Gauss quadrature rules
    [xi1, W1] = gaussRules(1);
    [xi2, W2] = gaussRules(2);
    [xi3, W3] = gaussRules(3);
    
    %// store dof indices for individual stress divergence components
    comp = [1, 7]; % uniaxial
    vcomp = [2, 6, 8, 12]; % transverse deflection along y and bending about z
    wcomp = [3, 5, 9, 11]; % transverse deflection along z and bending about y
    
    %/ define convenience variables for geo/mat props        
    G = E / (2 + 2 * nu);
    EA = E * A;
    kappaGA = kappa * G * A;
    kappaGJ = kappa * G * J;
    EIyy = E * Iyy;
    EIzz = E * Izz;
    Omega_yy = EIyy / kappaGA;
    Omega_zz = EIzz / kappaGA;
    y = params.Results.y_orientation;
    
    %// compute beam element stiffness matrix and store its system indices
    k = zeros(num_eqns, num_eqns, length(mesh(:,1))); 
    idx = zeros(length(mesh(:,1)), num_eqns);
    for e = 1:length(mesh(:,1))        
        %/ compute unit normal of beam longitudinal axis
        nx = (mesh(e,6:8) - mesh(e,2:4)) / norm(mesh(e,6:8) - mesh(e,2:4));
        
        %/ get nodal coordinates in natural system
        x = [nx, zeros(1,3); zeros(1,3), nx] * transpose([mesh(e,2:4), mesh(e,6:8)]);
        
        %/ compute a default unit normal for local y-axis or use input if provided
        valid_idx = min(e, length(y(:,1))); % idx for y defined on each element or once for all
        if (~any(y(valid_idx,:))) % if all zeros, use defualt
            % default assumes that y-axis rotates about z-axis by the same amount as x-axis
            ny = [-nx(2), nx(1), 0] / norm([-nx(2), nx(1), 0]);
        else
            % verify that y is a unit normal (rounded to nearest 12 decimal points)
            if (norm(y(valid_idx,:)) ~= 1)
                error(['The ''y_orientation'' property on element %d is not a unit normal. ',...
                       'The vector which defines the local y-axis must be normalized, i.e., ',...
                       'it must satisfy ''norm(y_orientation) == 1'''], e)
            end
            
            % take y normal as input value
            ny = y(valid_idx,:);
        end
        
        %/ assert that y-axis is perpindicular to x (rounded to nearest 12 decimal points)
        if (round(dot(nx, ny) / 1e-12) * 1e-12 ~= 0)
            error(['The ''y_orientation'' property on element %d is not perpindicular to the ',...
                   'beam longitudinal axis. These axes must be strictly orthogonal, i.e., they ',...
                   'must satisfy ''dot(x_orientation, y_orientation) == 0'''], e)
        end
        
        %/ compute unit normal for local z-axis
        nz = cross(nx, ny);
        
        %/ assemble Euler rotation matrix
        Phi = [nx; ny; nz];
        L = [Phi, zeros(3, 9); 
             zeros(3, 3), Phi, zeros(3, 6); 
             zeros(3, 6), Phi, zeros(3, 3); 
             zeros(3, 9), Phi];
        
        %/ evaluate derivative of Lagrange shape functions (constant polynomial)
        [~, dN] = evaluateLagrangeShapeFun(xi1);
        
        %/ compute Jacobian (constant over element)
        J = dN * x;
        
        %/ evaluate Gauss quadrature integral for uniaxial stiffness components at qp
        ku = W1 / J * transpose(dN) * dN;
        
        %/ compute axial and torsional stiffnesses
        k(comp,comp,e) = EA * ku;
        k((comp + 3),(comp + 3),e) = kappaGJ * ku;
        
        %/ compute shear contribution to y & z-deflection and y & z-bending stiffnesses
        for qp = 1:3
            % evaluate derivative of IIE shape functions for y-deflection at qp
            [~, dHv] = evaluateInterdependentShapeFun(xi3(qp), J, Omega_zz, 'uy');
            % evaluate IIE shape functions for z-bending at qp
            Homega = evaluateInterdependentShapeFun(xi3(qp), J, Omega_zz, 'rz');
            % evaluate Gauss quadrature intergral and accumulate stiffness over all qps
            k(vcomp,vcomp,e) = k(vcomp,vcomp,e) + W3(qp)...
                               * transpose(dHv - J * Homega) * (dHv / J - Homega);
            
            % evaluate derivative of IIE shape functions for z-deflection at qp 
            [~, dHw] = evaluateInterdependentShapeFun(xi3(qp), J, Omega_yy, 'uz');
            % evaluate IIE shape functions for y-bending at qp
            Hphi = evaluateInterdependentShapeFun(xi3(qp), J, Omega_yy, 'ry');
            % evaluate Gauss quadrature intergral and accumulate stiffness over all qps
            k(wcomp,wcomp,e) = k(wcomp,wcomp,e) + W3(qp)...
                               * transpose(dHw + J * Hphi) * (dHw / J + Hphi);
        end
        k(vcomp,vcomp,e) = kappaGA * k(vcomp,vcomp,e); % multiply beam props
        k(wcomp,wcomp,e) = kappaGA * k(wcomp,wcomp,e);
        
        %/ compute curvature contribution to y & z-deflection and y & z-bending stiffnesses
        kv = zeros(4, 4); kw = zeros(4, 4); % allocate a temporary space to store contributions
        for qp = 1:2
            % evaluate derivative of IIE shape functions for y-bending at qp
            [~, dHphi] = evaluateInterdependentShapeFun(xi2(qp), J, Omega_yy, 'ry');
            % evaluate Gauss quadrature intergral and accumulate stiffness over all qps
            kw = kw + W2(qp) / J * transpose(dHphi) * dHphi;
            
            % evaluate derivative of IIE shape functions for z-bending at qp
            [~, dHomega] = evaluateInterdependentShapeFun(xi2(qp), J, Omega_zz, 'rz');
            % evaluate Gauss quadrature intergral and accumulate stiffness over all qps
            kv = kv + W2(qp) / J * transpose(dHomega) * dHomega;
        end
        k(wcomp,wcomp,e) = k(wcomp,wcomp,e) + EIyy * kw; % multiply beam props and add contribution
        k(vcomp,vcomp,e) = k(vcomp,vcomp,e) + EIzz * kv;
        
        %/ rotate dofs into global coordinate system
        k(:,:,e) = transpose(L) * k(:,:,e) * L;
        
        %/ determine system indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,[1, 5]));
    end
end