%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x, y, field] = fieldT2D2(mesh, num_dofs, real_idx_diff, Q, varargin)
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
    x = zeros(Nx, 1, num_elems);
    y = zeros(Nx, 1, num_elems);
    field = zeros(Nx, 1, num_elems);

    %// set up element interpolation grid in natural coordinate system
    dxi = 2 / (Nx - 1);
    xi = -1:dxi:1;
    
    %// displacement index
    q_idx = zeros(4, 1);
    u_idx = [1, 3];
    v_idx = [2, 4];
    
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
        %/ compute unit normal of truss longitudinal axis
        nx = (mesh(e,5:6) - mesh(e,2:3)) / norm(mesh(e,5:6) - mesh(e,2:3));
        
        %/ get nodal coordinates in local system
        coords = [nx, zeros(1,2); zeros(1,2), nx] * transpose([mesh(e,2:3), mesh(e,5:6)]);
        
        %/ retrieve nodal displacements from global index
        q_idx(u_idx) = num_dofs * (transpose(mesh(e,[1, 4])) - 1) + 1;
        q_idx(v_idx) = q_idx(u_idx) + 1;
        q = Q(q_idx - real_idx_diff(q_idx));
        
        %/ use shape functions to interpolate nodal displacements to specified grid points
        for i = 1:Nx
            % evaluate Lagrange shape functions
            N = evaluateLagrangeShapeFun(xi(i));
            
            % map position of interpolation point in natural space into principal coordinates
            xy = [mesh(e,2), mesh(e,3)] + (N * coords - coords(1)) * nx;
            
            % interpolate horizontal and vertical components of uniaxial DOFs isoparametrically
            dofs(1) = N * q(u_idx);
            dofs(2) = N * q(v_idx);
            
            % apply scaled displacements to grid points and get their new positions      
            x(i,1,e) = xy(1) + scale_factor * dofs(1);
            y(i,1,e) = xy(2) + scale_factor * dofs(2);

            % store desired field value at interpolation point
            if ((length(comp) > 1) || (isempty(comp)))
                field(i,1,e) = norm(dofs(comp));
            else
                field(i,1,e) = dofs(comp);
            end
        end
    end
end