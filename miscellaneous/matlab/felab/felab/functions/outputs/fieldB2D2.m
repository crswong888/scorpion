function [x, y, field] = fieldB2D2(mesh, num_dofs, real_idx_diff, Q, varargin)
    %// parse additional for which component to output
    params = inputParser;
    addParameter(params, 'SamplesPerEdge', 10, @(x) ((isnumeric(x)) && (x >= 0)))
    addParameter(params, 'ScaleFactor', 1, @(x) isnumeric(x))
    valid_component = @(x) validatestring(x, {'disp_x', 'disp_y', 'rot_z', 'disp_mag', 'none'});
    addParameter(params, 'Component', 'disp_mag', @(x) any(valid_component(x)))
    parse(params, varargin{:})

    %// initialize element data
    Nx = params.Results.SamplesPerEdge;
    scale_factor = params.Results.ScaleFactor;
    num_elems = length(mesh(:,1));
    x = zeros(Nx, 1, num_elems);
    y = zeros(Nx, 1, num_elems);
    field = zeros(Nx, 1, num_elems);

    %// set up element interpolation grid in natural coordinate system
    dxi = 2 / (Nx - 1);
    xi = -1:dxi:1;
    
    %// displacement index
    q_idx = zeros(6, 1);
    u_idx = [1, 4];
    v_idx = [2, 3, 5, 6];
    
    %// loop through all elements on block
    for e = 1:num_elems
        %/ compute unit normal of beam longitudinal axis
        nx = (mesh(e,5:6) - mesh(e,2:3)) / norm(mesh(e,5:6) - mesh(e,2:3));
        
        %/ get nodal coordinates in local system
        coords = [nx, zeros(1,2); zeros(1,2), nx] * transpose([mesh(e,2:3), mesh(e,5:6)]);
        
        %/ assemble Euler rotation matrix
        Phi = [nx(1), nx(2), 0; -nx(2), nx(1), 0; 0, 0, 1];
        L = [Phi, zeros(3, 3); 
             zeros(3, 3), Phi];
        
        %/ compute Jacobian (constant over element)
        [~, dN] = evaluateLagrangeShapeFun(0);
        J = dN * coords;
        
        %/ retrieve nodal displacements from global index
        q_idx(u_idx) = num_dofs * (transpose(mesh(e,[1, 4])) - 1) + 1;
        q_idx(v_idx) = [q_idx(u_idx(1)) + 1; 
                        q_idx(u_idx(1)) + 2; 
                        q_idx(u_idx(2)) + 1;
                        q_idx(u_idx(2)) + 2];
        q = linsolve(L, Q(q_idx - real_idx_diff(q_idx)));

        %/ use shape functions to interpolate nodal displacements to specified grid points
        for i = 1:Nx
            % evaluate Lagrange and Hermite shape functions
            N = evaluateLagrangeShapeFun(xi(i));
            [H, dH] = evaluateHermiteShapeFun(xi(i), J);
            
            % interpolate degrees-of-freedom and rotate them into global coordinate space
            dofs = Phi * [N * q(u_idx); H * q(v_idx); dH * q(v_idx)];
            
            % apply scaled displacements to grid points and get their new positions
            x(i,1,e) = N * coords * nx(1) + scale_factor * dofs(1);
            y(i,1,e) = N * coords * nx(2) + scale_factor * dofs(2);

            %/ get desired nodal displacement value
            field(i,1,e) = norm([dofs(1), dofs(2)]);
        end
    end
end