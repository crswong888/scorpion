%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [k, idx] = computeT2D2Stiffness(mesh, isActiveDof, varargin)
    %// parse additional arguments for standard or rigid link element stiffness
    params = inputParser;
    addParameter(params, 'Rigid', false, @(x) islogical(x))
    addOptional(params, 'E', [])
    addOptional(params, 'A', [])
    addParameter(params, 'Penalty', sqrt(10^digits), @(x) ((isnumeric(x)) && (x > 0)))
    parse(params, varargin{:})

    %// establish local system size
    isLocalDof = logical([1, 1, 0, 0, 0, 0]); 
    num_eqns = 2 * length(isLocalDof(isLocalDof));
    
    %// establish Gauss quadrature rule
    [xi1, W1] = gaussRules(1);
    
    %// determine wether to compute a normal or rigid stifness matrix
    if (~params.Results.Rigid)
        %/ ensure Young's modulus and cross-sectional area provided
        validateRequiredParams(params, 'E', 'A');
        
        %/ standard truss geo/mat props
        EA = params.Results.E * params.Results.A;
    else
        %/ ensure that penalty coefficient is provided
        validateRequiredParams(params, 'Penalty');
    end
    
    %// compute truss element stiffness matrix and store its system indices
    k = zeros(num_eqns, num_eqns, length(mesh(:,1))); 
    idx = zeros(length(mesh(:,1)), num_eqns); 
    for e = 1:length(mesh(:,1))        
        %/ compute unit normal of truss longitudinal axis
        nx = (mesh(e,5:6) - mesh(e,2:3)) / norm(mesh(e,5:6) - mesh(e,2:3));
        
        %/ get nodal coordinates in local system
        L = [nx, zeros(1,2); zeros(1,2), nx];
        x = L * transpose([mesh(e,2:3), mesh(e,5:6)]);
        
        %/ evaluate derivative of Lagrange shape functions (constant polynomial)
        [~, dN] = evaluateLagrangeShapeFun(xi1);
        
        %/ compute Jacobian (constant over element)
        J = dN * x;
        
        %/ multiply geo/mat props by Jacobian to ignore effect of length on rigid element stiffness
        if (params.Results.Rigid)
            % geo/mat props is penalty stiffness for rigid elements
            EA = params.Results.Penalty * J;
        end
        
        %/ evaluate Gauss quadrature intergral and compute axial stiffness at qp
        k_bar = EA * W1 / J * transpose(dN) * dN;
        
        %/ resolve dofs into components in global coordinate system
        k(:,:,e) = transpose(L) * k_bar * L;
        
        %/ determine system indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,[1, 4]));
    end
end
