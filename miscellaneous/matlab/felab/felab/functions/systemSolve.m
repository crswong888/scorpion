function [q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F, precision)
    %// condition global stiffness matrix by eliminating rows i & j corresponding to known jth BCs
    K_old = K; F_old = F; % store the old system for later computations
    isBC = false(num_eqns,1); % initialize boolean for which dofs are prescribed BCs
    for s = 1:length(supports{:,1})
        for dof = 1:num_dofs
            if (supports{s,(2 + dof)} == 1) % if it is restrained, mark the index for elimination
                idx = num_dofs * (supports{s,2} - 1) + dof; % nominal dof index
                idx = idx - real_idx_diff(idx); % adjust to active real dof index
                isBC(idx) = true;
            end
        end
    end, K(isBC,:) = []; K(:,isBC) = []; F(isBC) = []; % eliminate restrained rows and columns
    
    %// solve unrestrained system
    q = zeros(num_eqns,1); % initialize so that original system array indices are preserved
    
    %/ first try to solve system using LU decomposition
    warning('off', 'MATLAB:singularMatrix')
    warning('off', 'MATLAB:nearlySingularMatrix') % these warnings are handled below
    [L, U, P, Q] = lu(K, [1 1]); % lower & upper triangular matrices plus a row & col permutations
    q(~isBC) = Q * (U \ (L \ (P * F)));
    
    %/ if LU failed, it is probably due to a problematic FE setup, but try gmres as a last resort
    warning('on', 'MATLAB:singularMatrix')
    warning('on', 'MATLAB:nearlySingularMatrix')
    if ((any(isnan(q))) || (1e-06 < norm(K * q(~isBC) - F) / norm(F)))
        fprintf(['LU decomposition was unsuccesful for the released DOF indices of the\n',...
                 'stiffness matrix with condition number for inversion, %g. Attempting to\n',...
                 'solve with GMRES...\n\n'], condest(K))
             
        q(~isBC) = gmres(K, F, size(K, 1), 1e-06);
        fprintf('\n')
    end

    %// determine the reaction forces at the supports from the solution
    Reactions = K_old(isBC,:) * q; 
    R = table(Reactions, find(isBC));
    
    %// report accuracy of solution to terminal
    F_old(isBC,:) = F_old(isBC,:) + Reactions; 
    res = norm(K_old * q - F_old) / norm(F_old);
    fprintf('Solve procedure complete! The system relative residual is %g.\n\n', res)
    
    %// ignore small discplacement and reaction values (if desired)
    if (nargin > 6) 
        q = round(q / precision) * precision;
        R{:,1} = round(R{:,1} / precision) * precision;
    end
end