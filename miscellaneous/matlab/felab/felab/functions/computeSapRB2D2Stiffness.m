function [k, idx] = computeSapRB2D2Stiffness(mesh, isActiveDof, varargin)

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

    %// establish system size
    isLocalDof = logical([1, 1, 0, 0, 0, 1]); 
    num_eqns = 2 * length(isLocalDof(isLocalDof));

    %// compute rigid beam element stiffness matrix and store the global indices
    k = zeros(num_eqns,num_eqns,length(mesh(:,1))); idx = zeros(length(mesh(:,1)),num_eqns);
    for e = 1:length(mesh(:,1))
        %/ compute beam element longitudinal axis vector
        dx = mesh(e,5) - mesh(e,2); dy = mesh(e,6) - mesh(e,3);
        %/ compute constraint coefficient matrix (enforces strains to be 0)
        B = [1, 0, -dy, -1,  0,  0;
             0, 1,  dx,  0, -1,  0;
             0, 0,   1,  0,  0, -1];
        %/ compute rigid stiffness matrix
        k(:,:,e) = p.Results.penalty(e) * transpose(B) * B;
        %/ determine global stiffness indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,1:3:4));
    end

end