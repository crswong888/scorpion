function [k, idx] = computeT2D2Stiffness(mesh, props, isActiveDof, varargin)
    %// parse additional argument for computing either a normal or rigid element stiffness
    params = inputParser;
    addParameter(params, 'rigid', false, @(x) islogical(x));
    parse(params, varargin{:});

    %// establish local system size
    isLocalDof = logical([1, 1, 0, 0, 0, 0]); 
    num_eqns = 2 * length(isLocalDof(isLocalDof));
    
    %// establish Gauss quadrature rule
    [xi1, W1] = gaussRules(1);
    
    %// compute truss element stiffness matrix and store its system indices
    k = zeros(num_eqns, num_eqns, length(mesh(:,1))); 
    idx = zeros(length(mesh(:,1)), num_eqns); 
    for e = 1:length(mesh(:,1))
        %/ compute length of element
        ell = norm(mesh(e,5:6) - mesh(e,2:3));
        
        %/ determine wether to compute a normal or rigid stifness matrix
        if (~params.Results.rigid)
            EA = props(e,1) * props(e,2); % standard truss geo/mat props
        else
            EA = props(e,1); % for link element - mat prop is penalty stiffness
            % multiply penalty by square length of the element to ensure length effects ignored
            if (ell > 1) % but only if the length is such that it would not reduce intended penalty
                EA = EA * ell^2; 
            end
        end   
        
        %/ compute unit normal of truss longitudinal axis
        nx = (mesh(e,5:6) - mesh(e,2:3)) / ell;
        
        %/ get nodal coordinates in natural system
        L = [nx, zeros(1,2); zeros(1,2), nx];
        x = L * transpose([mesh(e,2:3), mesh(e,5:6)]);
        
        %/ evaluate derivative of Lagrange shape functions (constant polynomial)
        [~, dN] = evaluateLagrangeShapeFun(xi1);
        
        %/ compute Jacobian (constant over element)
        J = dN * x;
        
        %/ evaluate Gauss quadrature intergral and compute axial stiffness at qp
        k_bar = EA * W1 / J * transpose(dN) * dN;
        
        %/ resolve dofs into components in global coordinate system
        k(:,:,e) = transpose(L) * k_bar * L;
        
        %/ determine system indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,[1, 4]));
    end
end
