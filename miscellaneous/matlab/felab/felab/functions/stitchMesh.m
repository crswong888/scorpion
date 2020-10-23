function [nodes, varargout] = stitchMesh(node_blocks, element_blocks, num_local, tol)
    %%% issue warning about under developed and that this isn't the best way to set up a mesh
    %%% comprised of several subdomains anyways... this is also gonna be really slow
    %%% a better way would be to have a single node system, and then assosciate the element blocks
    %%% to this master node map from the start, but this isn't always practical
    
    %// assert same number of node_blocks as element_blocks
    num_blocks = length(node_blocks);
    if (num_blocks ~= length(element_blocks))
        error('The number of node blocks must be equal to the number of element blocks.')
    end
    
    %// determine number of dimensions based on node_blocks input
    num_dims = length(node_blocks{1}{1,2:end});
    
    num_nodes = zeros(1, num_blocks);
    num_elems = zeros(1, num_blocks);
    for b = 1:num_blocks
        %// assert all node blocks use same dimensions
        if (num_dims ~= length(node_blocks{b}{1,2:end}))
            error('All blocks must use the same number of spatial dimensions.')
        end
        
        %// store number of nodes and elements per blocks
        num_nodes(b) = length(node_blocks{b}{:,1});
        num_elems(b) = length(element_blocks{b}{:,1});
    end
    
    %%% need to compute block overlaps by getting the extreme coordinates of each subdomain and then
    %%% searching only those overlapping zones for coincident nodes. If no overlap is found, then
    %%% there's some sort of discontinuity in the input, which is obviously an error
    
    %// accumulate a uniform increase to all node IDs in each succesive block
    inc = 0;
    for b = 2:num_blocks
        inc = inc + num_nodes(b - 1);
        node_blocks{b}{:,1} = node_blocks{b}{:,1} + inc;
        element_blocks{b}{:,2:(1 + num_local(b))} = element_blocks{b}{:,2:(1 + num_local(b))} + inc;
    end
    
    %// set a default nodal match tolerance if not specified as input
    if (nargin < 4)
        tol = 1e-16; % default is approximately double precision (16 decimals)
    end
    
    %// 
    varargout = cell(1, num_blocks);
    nodes = [];
    new_id = 0;
    for b = 1:(num_blocks - 1)
        for i = 1:num_nodes(b)
            new_id = new_id + 1
            nodes = cat(1, nodes, [new_id, node_blocks{b}{i,2:(1 + num_dims)}]);
            
            for e = 1:num_elems(b)
                for n = 2:(1 + num_local(b))
                    if (element_blocks{b}{e,n} == node_blocks{b}{i,1})
                        element_blocks{b}{e,n} = new_id;
                        break
                    end
                end
            end
                
            for bb = (b + 1):num_blocks
                j = 1;
                while (j <= num_nodes(bb))
                    if (all(round(node_blocks{b}{i,2:(1 + num_dims)} / tol) * tol...
                        == round(node_blocks{bb}{j,2:(1 + num_dims)} / tol) * tol))
                        for e = 1:num_elems(bb)
                            for n = 1:(1 + num_local(bb))
                                if (element_blocks{bb}{e,n} == node_blocks{bb}{j,1})
                                    element_blocks{bb}{e,n} = new_id;
                                    break
                                end
                            end
                        end
                        fprintf(['Consolidated node located at (',...
                                 num2str(node_blocks{bb}{j,2:(1 + num_dims)}),...
                                 ') on block %d\n\n'], bb)
                        
                        node_blocks{bb}(j,:) = [];
                        num_nodes(bb) = num_nodes(bb) - 1;
                        break
                    end
                    j = j + 1;
                end
            end
        end
    end
                        
            

end