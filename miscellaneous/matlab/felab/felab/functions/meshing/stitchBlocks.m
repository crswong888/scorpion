%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nodes, blocks] = stitchBlocks(node_blk, ele_blk, tol)    
    %// assert same number of node_blocks as element_blocks
    num_blocks = length(node_blk);
    if (num_blocks ~= length(ele_blk))
        error('The number of node blocks must be equal to the number of element blocks.')
    end
    
    %// convenience variables
    num_dims = length(node_blk{1}{1,2:end});
    num_local_nodes = zeros(1, num_blocks);
    
    for b = 1:num_blocks
        %// assert all node blocks use same dimensions
        if (num_dims ~= length(node_blk{b}{1,2:end}))
            error('All blocks must use the same number of spatial dimensions.')
        end
        
        %// assert all node IDs in block are unique
        if (~isequal(length(node_blk{b}{:,1}), length(unique(node_blk{b}{:,1}))))
            error('Duplicate node IDs found on block %d. A block must have all unique node IDs.', b)
        end
        
        %// get number of local nodes in block elements
        num_local_nodes(b) = length(ele_blk{b}{1,2:end});
    end
    
    %// accumulate a uniform increase to all node IDs in each succesive block
    inc = 0;
    for b = 2:num_blocks
        inc = inc + max(node_blk{b - 1}{:,1});
        node_blk{b}{:,1} = node_blk{b}{:,1} + inc;
        ele_blk{b}{:,2:(1 + num_local_nodes(b))} = ele_blk{b}{:,2:(1 + num_local_nodes(b))} + inc;
    end
    
    %// set a default nodal match tolerance if not specified as input
    if (nargin < 4)
        tol = 1e-16; % default is approximately double precision (16 decimals)
    end
    
    %// loop through subdomains and build a global node index of all nodes at unique points in space
    nodes = table();
    for b = 1:(num_blocks - 1)
        %/ it's possible that all nodes on a block have already been merged, so no need to proceed
        if (isempty(node_blk{b}))
            continue
        end
        
        %/ add block nodes to global index
        nodes = cat(1, nodes, node_blk{b});
        
        %/ compare nodal coordinates to those on all remaining blocks 
        for bb = (b + 1):num_blocks
            %/ find any coincident nodes
            [~, m1, m2] = intersect(round(node_blk{b}{:,2:(1 + num_dims)} / tol) * tol,...
                                    round(node_blk{bb}{:,2:(1 + num_dims)} / tol) * tol, 'rows');
            
            %/ if there are coincident nodes, merge them with current block
            if (~isempty(m2))
                for n = 2:(1 + num_local_nodes(bb))
                    [iscoincident, matchID] = ismember(ele_blk{bb}{:,n}, node_blk{bb}{m2,1});
                    ele_blk{bb}{iscoincident,n} = node_blk{b}{m1(nonzeros(matchID)),1};
                end
                node_blk{bb}(m2,:) = [];
                fprintf('Merged %d nodes on block %d.\n\n', length(m2), bb)
            end
        end
    end
    
    %// append nodes from final block to global index and then consolidate IDs
    [nodes, blocks] = consolidateNodeIDs(cat(1, nodes, node_blk{end}), ele_blk);
end