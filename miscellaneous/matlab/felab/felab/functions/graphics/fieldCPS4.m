function [x, y, field] = fieldCPS4(mesh, num_dofs, real_idx_diff, Q, varargin)
    %// parse additional for which component to output
    params = inputParser;
    valid_component = @(x) any(validatestring(x, {'x', 'y', 'magnitude'}));
    addParameter(params, 'SamplesPerElement', 10, @(x) ((isnumeric(x)) && (x >= 0)))
    addParameter(params, 'ScaleFactor', 1, @(x) isnumeric(x))
    addParameter(params, 'Component', 'magnitude', valid_component)
    parse(params, varargin{:})

    %// initialize element data
    data_pts = params.Results.SamplesPerElement;
    scale_factor = params.Results.ScaleFactor;
    num_elems = length(mesh(:,1));
    x = zeros(data_pts, data_pts, num_elems);
    y = zeros(data_pts, data_pts, num_elems);
    field = zeros(data_pts, data_pts, num_elems);

    %// set up element interpolation grid in natural coordinate system
    dxi = 2 / (data_pts - 1);
    xi = -1:dxi:1;
    eta = -1:dxi:1;
    
    %// displacement index
    q_idx = zeros(2 * length(mesh(1,:)) / 3, 1);
    u_idx = 1:2:length(q_idx);
    v_idx = u_idx + 1;
    
    %// loop through all elements on block
    for e = 1:num_elems
        %/ global node IDs and coordinates
        nodeIDs = transpose(mesh(e,1:3:end));
        coords = transpose([mesh(e,2:3:end); mesh(e,3:3:end)]);

        %/ retrieve the nodal displacements from global index
        q_idx(u_idx) = num_dofs * (nodeIDs - 1) + 1;
        q_idx(v_idx) = q_idx(u_idx) + 1;
        q = Q(q_idx - real_idx_diff(q_idx));

        %/ use shape functions to interpolate nodal displacements to specified grid points
        for i = 1:data_pts
            for j = 1:data_pts
                % evaluate shape functions and get displacement values
                N = evaluateCPS4ShapeFun(xi(i), eta(j));
                u = N * q(u_idx);
                v = N * q(v_idx);

                % apply scaled displacements to grid points and get their new positions
                x(i,j,e) = N * coords(:,1) + scale_factor * u;
                y(i,j,e) = N * coords(:,2) + scale_factor * v;

                %/ get desired nodal displacement value
                field(i,j,e) = norm([u, v]);
            end
        end
    end
end