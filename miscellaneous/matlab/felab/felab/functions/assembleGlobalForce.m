function F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces)
    %// construct the global force vector
    F = zeros(num_eqns,1);
    for f = 1:length(forces{:,1})
        for dof = 1:length(forces{1,3:end})
            if (forces{f,(2 + dof)} ~= 0)
                idx = num_dofs * (forces{f,2} - 1) + dof; % nominal dof index
                idx = idx - real_idx_diff(idx); % adjust to active real dof index
                F(idx) = F(idx) + forces{f,2+dof}; % add the value
            end
        end
    end
end

% NOTE: If a nominal dof has been deactivated, no forces should be applied to it
% could put a check to confirm that length(F) = num_eqns at the end here.