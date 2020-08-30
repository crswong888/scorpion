function K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, idx)

    %// add all block's element's local stiffnesses to global matrix - store only nonzero entries
    K = sparse(num_eqns,num_eqns);
    for block = 1:length(k) % for all unique element types
        real_idx = zeros(1,length(idx{block}(1,:))); % initialize
        for e = 1:length(idx{block}(:,1))
            %/ first, adjust the nominal indices to the active real dofs in the global system
            for i = 1:length(idx{block}(e,:)) 
                real_idx(i) = idx{block}(e,i) - real_idx_diff(idx{block}(e,i));
            end
            K(real_idx,real_idx) = K(real_idx,real_idx) + k{block}(:,:,e);
        end
    end

end

%// ignore the sparse matrix for-loop indexing warning
%#ok<*SPRIX>

% TODO: assemble K using a more efficient sparse indexing scheme