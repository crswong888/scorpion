function K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, idx)
    %// assemble global stiffness matrix
    K = sparse(num_eqns,num_eqns); % save memory by using sparse storage
    for block = 1:length(k)
        real_idx = zeros(1,length(idx{block}(1,:))); % initialize
        for e = 1:length(idx{block}(:,1))
            %/ first, adjust nominal indices to active real dofs in global system
            for i = 1:length(idx{block}(e,:)) 
                real_idx(i) = idx{block}(e,i) - real_idx_diff(idx{block}(e,i));
            end
            
            %/ add element stifnesses to global matrix 
            K(real_idx,real_idx) = K(real_idx,real_idx) + k{block}(:,:,e); %#ok<SPRIX>
        end
    end
end