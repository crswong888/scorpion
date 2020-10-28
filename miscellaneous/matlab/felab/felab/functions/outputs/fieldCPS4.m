function [x, y, field] = fieldCPS4(mesh, num_dofs, real_idx_diff, Q, varargin)
    %// parse additional inputs
    params = inputParser;
    addParameter(params, 'SamplesPerEdge', 10, @(x) ((isnumeric(x)) && (x >= 0)))
    addParameter(params, 'ScaleFactor', 1, @(x) isnumeric(x))
    valid_component = @(x) validatestring(x, {'disp_x', 'disp_y', 'disp_mag', 'none'});
    addParameter(params, 'Component', 'disp_mag', @(x) any(valid_component(x)))
    parse(params, varargin{:})

    %// initialize element data
    Nx = params.Results.SamplesPerEdge;
    scale_factor = params.Results.ScaleFactor;
    num_elems = length(mesh(:,1));
    x = zeros(Nx, Nx, num_elems);
    y = zeros(Nx, Nx, num_elems);
    field = zeros(Nx, Nx, num_elems);

    %// set up element interpolation grid in natural coordinate system
    dxi = 2 / (Nx - 1);
    xi = -1:dxi:1;
    eta = -1:dxi:1;
    
    %// displacement index
    q_idx = zeros(8, 1);
    u_idx = [1, 3, 5, 7];
    v_idx = [2, 4, 6, 8];
    
    %// set position of DOF to retrieve at interpolation points
    component = valid_component(params.Results.Component);
    if (strcmp(component, 'disp_mag'))
        comp = [1, 2];
    elseif (strcmp(component, 'disp_x'))
        comp = 1;
    elseif (strcmp(component, 'disp_y'))
        comp = 2;
    elseif (strcmp(component, 'none'))
        comp = [];
    end
    
    %// loop through all elements on block
    for e = 1:num_elems
        %/ global node coordinates
        coords = transpose([mesh(e,2:3:end); mesh(e,3:3:end)]);

        %/ retrieve nodal displacements from global index
        q_idx(u_idx) = num_dofs * (transpose(mesh(e,1:3:end)) - 1) + 1;
        q_idx(v_idx) = q_idx(u_idx) + 1;
        q = Q(q_idx - real_idx_diff(q_idx));

        %/ use shape functions to interpolate nodal displacements to specified grid points
        for i = 1:Nx
            for j = 1:Nx
                % evaluate Lagrange shape functions
                N = evaluateCPS4ShapeFun(xi(i), eta(j));
                
                % interpolate degrees-of-freedom
                dofs = [N * q(u_idx); N * q(v_idx)];

                % apply scaled displacements to grid points and get their new positions
                x(i,j,e) = N * coords(:,1) + scale_factor * dofs(1);
                y(i,j,e) = N * coords(:,2) + scale_factor * dofs(2);

                %/ store desired field value at interpolation point
                if (length(comp) > 1)
                    field(i,j,e) = norm(dofs(comp));
                else
                    field(i,j,e) = dofs(comp);
                end
            end
        end
    end
end