function [nodes, blocks] = consolidateNodeIDs(nodes, blocks, num_local_nodes)
    %// this assumes that input is a cell array of element blocks - convert to cell if not
    if (~iscell(blocks))
        blocks = {blocks};
    end
    
    %// store input data sizes
    num_nodes = length(nodes{:,1});
    num_blocks = length(blocks);
    
    %// search for duplicate node IDs
    duplicates = [];
    for i = 1:(num_nodes - 1)
        isduplicate = (any(nodes{i,1} == nodes{[1:(i - 1), (i + 1):end],1}));
        if ((isduplicate) && (~ismember(nodes{i,1}, duplicates)))
            duplicates = cat(2, duplicates, nodes{i,1});
        end
    end
    
    %// assert no duplicates
    if (~isempty(duplicates))
        error(['Node IDs must be strictly unique. Duplicate IDs found: ', num2str(duplicates), '.'])
    end
    
    %// store global indices of element local nodes on all blocks
    og_idx = cell(num_blocks, max(num_local_nodes));
    for b = 1:num_blocks
        for n = 2:(1 + num_local_nodes(b))
            [hasnode, og_idx{b,n}] = ismember(blocks{b}{:,n}, nodes{:,1});
            
            %/ assert that all element nodes have a corresponding global ID
            if (any(~hasnode))
                mismatched = num2str(transpose(blocks{b}{~hasnode,1}));
                error(['Local node %d on element(s) (', mismatched, ') on block %d does not ',...
                       'correspond to any nodes in the global index.'], n - 1, b)
            end
        end
    end
    
    %// sort node IDs in order of succesive integer values
    nodes{:,1} = transpose(1:num_nodes);
    
    %// now update the element local node IDs
    for b = 1:num_blocks
        for n = 2:(1 + num_local_nodes(b))
            blocks{b}{:,n} = nodes{og_idx{b,n},1};
        end
    end     
end