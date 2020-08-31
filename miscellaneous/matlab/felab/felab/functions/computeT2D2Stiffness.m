function [k, idx] = computeT2D2Stiffness(mesh, props, isActiveDof, varargin)

    %// parse additional argument to for computing either a normal or rigid element stiffness
    p = inputParser; % create instance to access the inputParser class
    addParameter(p, 'rigid', false, @(x) islogical(x));
    parse(p, varargin{:});

    %// establish local system size
    isLocalDof = logical([1, 1, 0, 0, 0, 0]); 
    num_eqns = 2 * length(isLocalDof(isLocalDof));
    
    %// establish the Gauss quadrature point (1-point rule for linear)
    gauss = 0; weight = 2;
    
    %// compute the truss element stiffness matrix and store the global indices
    k = zeros(num_eqns,num_eqns,length(mesh(:,1))); idx = zeros(length(mesh(:,1)),num_eqns);
    for e = 1:length(mesh(:,1))
        %/ compute the unit normal of the truss axis vector
        dx = mesh(e,5) - mesh(e,2); dy = mesh(e,6) - mesh(e,3); ell = sqrt(dx * dx + dy * dy);
        %/ compute the Euler transformation matrix
        m = dx / ell; n = dy / ell; Phi = [m, n, 0, 0; 0, 0, m, n];
        for qp = 1
            %/ evaluate the second derivative of the shape functions at the QPs
            [~, dN] = evaluateT2D2ShapeFun(gauss(qp));
            %/ compute the QP Jacobian
            J = dN * Phi * [mesh(e,2); mesh(e,3); mesh(e,5); mesh(e,6)];
            %/ compute the element B matrix
            B = 1 / J * dN * Phi;
            %/ evaluate QP intergrals and accumulate element local stiffness
            JxW = J * weight(qp);
            k(:,:,e) = k(:,:,e) + transpose(B) * B * JxW;
        end
        
        %/ determine wether to compute a normal or rigid stifness matrix
        if (~p.Results.rigid)
            k(:,:,e) = props(e,1) * props(e,2) * k(:,:,e); % multiply by EA
        else
            % multiply penalty by square length of the element to ensure length effects ignored
            if (ell > 1) % but only if the length is such that it would not reduce intended penalty
                penalty = props(e,1) * ell^2; % assumes first prop for the elem is a penalty coeff
            end
            k(:,:,e) = penalty * k(:,:,e);
        end   
        
        %/ determine the global stiffness indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,1:3:4));
    end

end