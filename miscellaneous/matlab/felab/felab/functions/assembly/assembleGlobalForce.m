%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces)
    %// assemble global applied force vector
    F = sparse(num_eqns, 1); % save memory by using sparse storage
    for f = 1:length(forces{:,1})
        for dof = 1:length(forces{1,3:end})
            if (forces{f,(2 + dof)} ~= 0)
                %/ nominal dof index
                idx = num_dofs * (forces{f,2} - 1) + dof;
                
                %/ active real dof index
                real_idx = idx - real_idx_diff(idx);
                
                %/ add nodal forces to global vector
                F(real_idx) = F(real_idx) + forces{f,2+dof}; %#ok<SPRIX>
            end
        end
    end
end