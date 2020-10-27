function [k, idx] = computeRB3D2Stiffness(mesh, isActiveDof, varargin)  
    %// Parse additional argument for penalty stiffness. If not provided - default is to use "The
    %// Square Root Rule."
    params = inputParser;
    addParameter(params, 'penalty', sqrt(10^digits), @(x) (isnumeric(x) && (x > 0)));
    parse(params, varargin{:});

    %// establish local system size
    isLocalDof = logical([1, 1, 1, 1, 1, 1]); 
    num_eqns = 2 * length(isLocalDof(isLocalDof));

    %// compute beam element stiffness matrix and store its system indices
    k = zeros(num_eqns, num_eqns, length(mesh(:,1))); 
    idx = zeros(length(mesh(:,1)), num_eqns);
    for e = 1:length(mesh(:,1))
        %/ compute longitudinal axis vector
        dx = mesh(e,6) - mesh(e,2); 
        dy = mesh(e,7) - mesh(e,3);
        dz = mesh(e,8) - mesh(e,4);
        
        %/ set constraint coefficient matrix (enforces strains to be 0)
        B = [1, 0, 0,   0,  dz, -dy, -1,  0,  0,  0,  0,  0;
             0, 1, 0, -dz,   0,  dx,  0, -1,  0,  0,  0,  0;
             0, 0, 1,  dy, -dx,   0,  0,  0, -1,  0,  0,  0;
             0, 0, 0,   1,   0,   0,  0,  0,  0, -1,  0,  0;
             0, 0, 0,   0,   1,   0,  0,  0,  0,  0, -1,  0;
             0, 0, 0,   0,   0,   1,  0,  0,  0,  0,  0, -1];
         
        %/ compute rigid stiffness matrix
        k(:,:,e) = params.Results.penalty * transpose(B) * B;
        
        %/ determine system indices
        idx(e,:) = getGlobalDofIndex(isLocalDof, isActiveDof, mesh(e,[1, 5]));
    end
end