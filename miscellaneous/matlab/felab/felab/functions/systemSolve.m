function [q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F, precision)

    %// condition global stiffness matrix by eliminating rows i & j corresponding to known jth BCs
    K_old = K; F_old = F; % store the old system for later computations
    isBC = false(num_eqns,1); % initialize boolean for which dofs are prescribed BCs
    for s = 1:length(supports{:,1})
        for dof = 1:num_dofs
            if (supports{s,2+dof} == 1) % if it is restrained, mark the index for elimination
                idx = num_dofs * (supports{s,2} - 1) + dof; % nominal dof index
                idx = idx - real_idx_diff(idx); % adjust to active real dof index
                isBC(idx) = true; 
            end
        end
    end, K(isBC,:) = []; K(:,isBC) = []; F(isBC) = []; % eliminate restrained rows and columns
    
    %// solve global system using LU factorization with full pivoting
    q = zeros(num_eqns,1); % initialize so that original system array indices are preserved
    [L, U, P, Q] = lu(K, [1 1]); % lower & upper triangular matrices plus a row & col permutations
    q(~isBC) = Q * (U \ (L \ (P * F)));

    %// determine the reaction forces at the supports from the solution
    Reactions = K_old(isBC,:) * q; Index = find(isBC);
    R = table(Reactions, Index); %/ return reactions as table with the corresponding dof index
    
    %// report accuracy of solution to terminal
    F_old(isBC,:) = F_old(isBC,:) + Reactions; sqnorm = norm(K_old * q - F_old)^2;
    fprintf('Solver converged with a residual norm of %g\n\n', sqnorm);
    
    %// ignore small discplacement values (if desired)
    if (nargin > 6), q = round(q / precision) * precision; end

end