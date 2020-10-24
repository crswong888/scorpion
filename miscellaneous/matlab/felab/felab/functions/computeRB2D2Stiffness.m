function [k, idx] = computeRB2D2Stiffness(mesh, isActiveDof, varargin)  
    %// Parse additional argument for penalty stiffness. If not provided - default is to use "The
    %// Square Root Rule," described in C. Fellipa (2004), "Introduction to Finite Element Methods."
    %// University of Colorado, Boulder, CO., with max(K(i,j)) = 0.
    params = inputParser;
    default_penalty = sqrt(10^digits) * ones(length(mesh(:,1)),1);
    addParameter(params, 'penalty', default_penalty, @(x) isnumeric(x) && all(x > 0));
    parse(params, varargin{:});

    %// establish local system size
    isLocalDof = logical([1, 1, 0, 0, 0, 1]);
    num_eqns = 2 * length(isLocalDof(isLocalDof));

    %// compute beam element stiffness matrix and store its system indices
    k = zeros(num_eqns, num_eqns, length(mesh(:,1))); 
    idx = zeros(length(mesh(:,1)), num_eqns);
    for e = 1:length(mesh(:,1))
        %/ compute longitudinal axis vector
        dx = mesh(e,5) - mesh(e,2); 
        dy = mesh(e,6) - mesh(e,3);
        
        %/ set constraint coefficient matrix (enforces strains to be 0)
        B = [1, 0, -dy, -1,  0,  0;
             0, 1,  dx,  0, -1,  0;
             0, 0,   1,  0,  0, -1];
        
        %/ compute rigid stiffness matrix
        k(:,:,e) = params.Results.penalty(e) * transpose(B) * B;
        
        %/ determine system indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,[1, 4]));
    end
end