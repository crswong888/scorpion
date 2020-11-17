%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function force_data = distributeBeamForce(nodes, elements, ID, W, varargin)
    %// parse value for transverse loading function (always applied orthoganal to beam)
    params = inputParser;
    %/ only 2-noded elements are valid here - and they should be beam elements
    valid_element = @(x) (istable(x) && (length(x{1,:}) == 3));
    addRequired(params, 'elements', valid_element)
    %/ param 'W' can be either a constant or a function handle describing load variation over length
    valid_load = @(x) validateattributes(x, {'double', 'function_handle'}, {'scalar'});
    addRequired(params, 'W', valid_load)
    %/ 'NormalDirection' (for 3D) must be a unit normal vector - uses default if all zeros provided
    valid_normal = @(x) ((length(x) == 3) && ((round(norm(x) / 1e-12) * 1e-12 == 1) || ~any(x)));
    addParameter(params, 'NormalDirection', [0, 0, 0], valid_normal)
    parse(params, elements, W, varargin{:})
    
    %// if 'W' is a constant, convert it to a function handle for consistent operations
    if (~isa(W, 'function_handle'))
        W = @(x) W;
    end
    
    %// get number of dimensions
    num_dims = length(nodes{1,2:end});
    
    %// assert that 'NormalDirection' is only specified for space frame elements
    if ((num_dims == 2) && any(params.Results.NormalDirection))
        error('The ''NormalDirection'' argument is only valid for 3-dimensional beam elements. ')
    end
    
    %// get nodal coordinates of beam
    [~, ID] = ismember(ID, elements{:,1});
    [~, idx] = ismember(elements{ID,2:3}, nodes{:,1});
    coords = nodes{idx,2:end};
    
    %// compute beam normal
    nx = (coords(2,:) - coords(1,:)) / norm(coords(2,:) - coords(1,:));
    
    %// assign 'NormalDirection' property to reference variable
    if (num_dims == 2)
        nw = [-nx(2), nx(1)] / norm([-nx(2), nx(1)]);
    elseif (~any(params.Results.NormalDirection))
        nw = [-nx(2), nx(1), 0] / norm([-nx(2), nx(1), 0]);
    else        
        % use input to set normal direction of force
        nw = params.Results.NormalDirection;
    end
    
    %// assert 'NormalDirection' is transverse to beam axis (rounded to nearest 12 decimal points)
    if (round(dot(nx, nw) / 1e-12) * 1e-12 ~= 0)
        error(['The ''NormalDirection'' specified for the distributed force on beam element %d ',...
               'is not perpindicular to the beam longitudinal axis. The loading must be ',...
               'directed transverse to the beam.'], ID)
    end
    
    %// get nodal coordinates in local system
    x = transpose(nx * transpose(coords));
    
    %/ evaluate derivative of Lagrange shape functions (constant polynomial)
    [~, dN] = evaluateLagrangeShapeFun(gaussRules(1));

    %/ compute Jacobian (constant over element)
    J = dN * x;
    
    %// initialize array of nodal forces
%     if (num_dims == 2)
%         nodal_forces = zeros(4, 1);
%     else
%         nodal_forces = zeros(8, 1);
%     end
    
    %// use numerical integration to handle arbitrary loads (not just constant/monomial/polynomial)
    func = @(xi) W(evaluateLagrangeShapeFun(xi) * x) * transpose(evaluateHermiteShapeFun(xi, J));
    local_forces = J * integral(func, -1, 1, 'ArrayValued', true);
    
%     select = @(v, i) v(i);
%     integrand = @(xi) select(func(xi), 2);
%     select(func(0), 2)
%     integrand(0)
%     func(0)
%     integral(integrand,-1, 1)
    
%     nodal_forces = zeros(4,1);
%     num_pts = 2000;
%     dxi = 2 / num_pts;
%     xi = -1;
%     integrand_old = W(evaluateLagrangeShapeFun(xi) * x) * transpose(evaluateHermiteShapeFun(xi, J));
%     for i = 1:num_pts
%         xi = xi + dxi;
%         integrand = W(evaluateLagrangeShapeFun(xi) * x) * transpose(evaluateHermiteShapeFun(xi, J));
%         nodal_forces = nodal_forces + dxi * (integrand + integrand_old);
%         
%         integrand_old = integrand;
%     end
%     
%     nodal_forces = J / 2 * nodal_forces;
    
    if (num_dims == 2)
        F = [local_forces([1, 3]), local_forces([2, 4])] * [nw, 0; 0, 0, 1];
    else
        F = local_forces * nw;
        F = [F(1,:), F(2,:); F(3,:), F(4,:)];
    end
    
    force_data = [F, coords];
end