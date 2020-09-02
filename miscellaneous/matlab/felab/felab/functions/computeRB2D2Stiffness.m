function [k, idx] = computeRB2D2Stiffness(mesh, isActiveDof, varargin)
    
    %%% Note: the penalty stiffness should be much larger in magnitude than the largest applied
    %%% forces and the largest member stiffness (e.g., EA/L, EI/L^3, or some D-matrix)
    %%%
    %%% Note: The effects of stiffness loss due to large member lengths are ignored.
    
    %// Parse additional argument for penalty stiffness. If not provided - default is to use "The
    %// Square Root Rule," described in C. Fellipa (2004), "Introduction to Finite Element Methods."
    %// University of Colorado, Boulder, CO., with max(K(i,j)) = 0.
    p = inputParser;
    RealPositiveArray = @(x) isnumeric(x) && all(x > 0); % valid input type for penalty
    default_penalty = sqrt(10^digits) * ones(length(mesh(:,1)),1);
    addParameter(p, 'penalty', default_penalty, RealPositiveArray);
    parse(p, varargin{:});

    %// establish local system size
    isLocalDof = logical([1, 1, 0, 0, 0, 1]); 
    num_eqns = 2 * length(isLocalDof(isLocalDof));

    %// establish the Gauss quadrature point (2-point rule for linear or quadratic)
    gauss(1) = -1 / sqrt(3); gauss(2) = -gauss(1); weight = ones(1,2); % W_i at each QP
    
    %// compute the rigid beam element stiffness matrix and store the global indices
    k = zeros(num_eqns,num_eqns,length(mesh(:,1))); idx = zeros(length(mesh(:,1)),num_eqns);
    for e = 1:length(mesh(:,1))     
        %/ compute the unit normal of the beam axis vector
        dx = mesh(e,5) - mesh(e,2); dy = mesh(e,6) - mesh(e,3); ell = sqrt(dx * dx + dy * dy);
        %/ multiply penalty by square length of the element to ensure length effects ignored
        penalty = p.Results.penalty(e);
        if (ell > 1) % but only if the length is such that it would not reduce intended penalty
            penalty = penalty * ell^2;
        end
        %/ compute the Euler transformation matrix
        l = dx / ell; m = dy / ell;
        Phi = [[l, m, 0; -m, l, 0; 0, 0, 1], zeros(3,3); zeros(3,3), [l, m, 0; -m, l, 0; 0, 0, 1]];
        for qp = 1:2
            %/ evaluate the second derivative of the shape functions at the QPs
            [~, dN, ~, d2H] = evaluateB2D2ShapeFun(gauss(qp));
            %/ compute the QP Jacobian
            J = dN * [l, m, 0, 0; 0, 0, l, m] * [mesh(e,2); mesh(e,3); mesh(e,5); mesh(e,6)];
            %/ compute the element B (uniaxial) and L (bending) stress-strain interpolation matrices
            B = 1 / J * [dN(1), 0, 0, dN(2), 0, 0] * Phi;
            L = 1 / (J * J) * [0, d2H(1), d2H(2) * J, 0, d2H(3), d2H(4) * J] * Phi;
            %/ evaluate qp intergrals and accumulate element local stiffness
            JxW = J * weight(qp);
            k(:,:,e) = k(:,:,e) + JxW * (transpose(B) * B + transpose(L) * L);
        end, k(:,:,e) = penalty * k(:,:,e); % multiply by penalty stiffness coefficient
        %/ determine the global stiffness indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,1:3:4));
    end

end