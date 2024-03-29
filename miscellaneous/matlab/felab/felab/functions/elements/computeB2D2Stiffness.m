%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [k, idx] = computeB2D2Stiffness(mesh, isActiveDof, varargin)
    %// parse additional arguments for standard or rigid beam element stiffness
    params = inputParser;
    addParameter(params, 'Rigid', false, @(x) islogical(x))
    addOptional(params, 'E', [])
    addOptional(params, 'A', [])
    addOptional(params, 'I', [])
    addParameter(params, 'Penalty', sqrt(10^digits), @(x) ((isnumeric(x)) && (x > 0)))
    parse(params, varargin{:})

    %// establish local system size
    isLocalDof = logical([1, 1, 0, 0, 0, 1]);
    num_eqns = 2 * length(isLocalDof(isLocalDof));

    %// establish Gauss quadrature rules
    [xi1, W1] = gaussRules(1);
    [xi2, W2] = gaussRules(2);
    
    %// store dof indices for individual stress divergence components
    comp = [1, 4]; % uniaxial 
    vcomp = [2, 3, 5, 6]; % transverse deflection along y and bending about z
    
    %// determine wether to compute a normal or rigid stifness matrix
    if (~params.Results.Rigid)
        %/ ensure Young's modulus and cross-sectional geometry props provided
        validateRequiredParams(params, 'E', 'A', 'I');
        
        %/ standard beam geo/mat props
        EA = params.Results.E * params.Results.A;
        EI = params.Results.E * params.Results.I;
    else
        %/ ensure that penalty coefficient is provided
        validateRequiredParams(params, 'Penalty');
    end
    
    %// compute beam element stiffness matrix and store its system indices
    k = zeros(num_eqns, num_eqns, length(mesh(:,1))); 
    idx = zeros(length(mesh(:,1)), num_eqns); 
    for e = 1:length(mesh(:,1))      
        %/ compute unit normal of beam longitudinal axis
        nx = (mesh(e,5:6) - mesh(e,2:3)) / norm(mesh(e,5:6) - mesh(e,2:3));
        
        %/ get nodal coordinates in local system
        x = [nx, zeros(1,2); zeros(1,2), nx] * transpose([mesh(e,2:3), mesh(e,5:6)]);
        
        %/ assemble Euler rotation matrix
        Phi = [nx(1), nx(2), 0; -nx(2), nx(1), 0; 0, 0, 1];
        L = [Phi, zeros(3, 3); 
             zeros(3, 3), Phi];
        
        %/ evaluate derivative of Lagrange shape functions (constant polynomial)
        [~, dN] = evaluateLagrangeShapeFun(xi1);
        
        %/ compute Jacobian (constant over element)
        J = dN * x;
        
        %/ multiply geo/mat props by Jacobian to ignore effect of length on rigid element stiffness
        if (params.Results.Rigid)
            % geo/mat props is penalty stiffness for rigid elements
            EA = params.Results.Penalty * J;
            EI = params.Results.Penalty * J^3;
        end
        
        %/ evaluate Gauss quadrature intergral and compute axial stiffness at qp
        k(comp,comp,e) = EA * W1 / J * transpose(dN) * dN;
        
        %/ compute y-deflection and z-bending stiffnesses
        for qp = 1:2
            % evaluate second derivative of Hermite shape functions at qp
            [~, ~, d2H] = evaluateHermiteShapeFun(xi2(qp), J);
            % evaluate Gauss quadrature intergral and accumulate stiffness over all qps
            k(vcomp,vcomp,e) = k(vcomp,vcomp,e) + W2(qp) * transpose(d2H) * d2H;
        end
        k(vcomp,vcomp,e) = EI * k(vcomp,vcomp,e) / J^3; % multiply beam props
        
        %/ rotate dofs into global coordinate system
        k(:,:,e) = transpose(L) * k(:,:,e) * L;
        
        %/ determine system indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,[1, 4]));
    end
end