%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x, y, field] = fieldB2D2(mesh, num_dofs, real_idx_diff, Q, varargin)
    %// parse additional inputs
    params = inputParser;
    addParameter(params, 'SamplesPerEdge', 10, @(x) ((isnumeric(x)) && (x >= 0)))
    addParameter(params, 'ScaleFactor', 1, @(x) isnumeric(x))
    valid_component = @(x) validatestring(x, {'disp_x', 'disp_y', 'rot_z', 'disp_mag', 'none'});
    addParameter(params, 'Component', 'disp_mag', @(x) any(valid_component(x)))
    addParameter(params, 'BeamForceElementID', [])
    valid_forces = @(x) (isnumeric(x) || isa(x, 'function_handle'));
    addParameter(params, 'BeamForce', {},...
                 @(x) all(cellfun(valid_forces, {x})) || all(cellfun(valid_forces, x)));
    addParameter(params, 'FlexRigidity', 1, @(x) ((isnumeric(x)) && (x >= 0)))
    parse(params, varargin{:})

    %/ simplify pointer syntax
    Nx = params.Results.SamplesPerEdge;
    scale_factor = params.Results.ScaleFactor;
    load_idx = params.Results.BeamForceElementID;
    load_funcs = params.Results.BeamForce;
    EI = params.Results.FlexRigidity;
    
    %// assert that 'BeamForceElementID' and 'BeamForce' are specified together
    validateRequiredParams(params, 'BeamForceElementID', 'BeamForce')
    
    %/ additional parsing required if distributed forces provided
    if (all(~ismember({'BeamForceElementID', 'BeamForceID'}, params.UsingDefaults)))
        % require 'FlexRigidity' param needed for interpolating distributed load DOF contributions
        validateRequiredParams(params, 'FlexRigidity')
        
        % assert that parameters are of equal length
        if (length(load_idx) ~= length(load_funcs))
            error(['The length of ''BeamForceElementID'' must be equal to the length of ',...
                   '''BeamForce''.'])
        end
        
        % convert 'BeamForce' to cell array of function handles if it is not
        if (~iscell(load_funcs)), load_funcs = num2cell(load_funcs); end
        for f = 1:length(load_idx)
            if (~isa(load_funcs{f}, 'function_handle'))
                load_funcs{f} = @(x) load_funcs{f};
            end
        end
    end

    %// initialize element data
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
    
    %// set position of DOF to retrieve at interpolation points
    component = valid_component(params.Results.Component);
    if (strcmp(component, 'disp_mag'))
        comp = [1, 2];
    elseif (strcmp(component, 'disp_x'))
        comp = 1;
    elseif (strcmp(component, 'disp_y'))
        comp = 2;
    elseif (strcmp(component, 'rot_z'))
        comp = 3;
    elseif (strcmp(component, 'none'))
        comp = [];
    end
    
    %// loop through all elements on block
    syms w(s) % this is needed as a null placeholder for symbolic integration of distributed loads
    for e = 1:num_elems
        %/ compute unit normal of beam longitudinal axis
        nx = (mesh(e,5:6) - mesh(e,2:3)) / norm(mesh(e,5:6) - mesh(e,2:3));
        ny = [-nx(2), nx(1)];
        
        %/ get nodal coordinates in local system
        coords = [nx, zeros(1,2); zeros(1,2), nx] * transpose([mesh(e,2:3), mesh(e,5:6)]);
        
        %/ assemble Euler rotation matrix
        Phi = [nx, 0; ny, 0; 0, 0, 1];
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
        q = L * Q(q_idx - real_idx_diff(q_idx));
        
        %/ compute deflection due to continuous forces, if any, to superpose onto Hermite shape funs
        We = load_funcs(ismember(load_idx, e));
        
        % sum and quadruple-integrate all load functions to get deflection contribution
        intvals = cellfun(@(f) subs(int(int(int(int(w)))), w, f), We, 'UniformOutput', false);
        p = @(s) double(sum(cellfun(@(f) f(s), intvals))) / EI;
        
        % sum and triple-integrate all load functions to get rotation contribution
        intvals = cellfun(@(f) subs(int(int(int(w))), w, f), We, 'UniformOutput', false);
        dp = @(s) double(sum(cellfun(@(f) f(s), intvals))) / EI;
        
        % get nodal values of DOFs which are used to restrict load contributions to between nodes
        pnode = [p(coords(1)); dp(coords(1)); p(coords(2)); dp(coords(2))];
        
        %/ use shape functions to interpolate nodal displacements to specified grid points
        for i = 1:Nx
            % evaluate Lagrange and Hermite shape functions
            N = evaluateLagrangeShapeFun(xi(i));
            [H, dH] = evaluateHermiteShapeFun(xi(i), J);
            
            % map position of interpolation point in natural space into principal coordinates
            s = N * coords;
            xy = [mesh(e,2), mesh(e,3)] + (s - coords(1)) * nx;
            
            % interpolate degrees-of-freedom and rotate them into global coordinate space
            u = N * q(u_idx);
            v = p(s) + H * (q(v_idx) - pnode);
            theta = dp(s) + dH * (q(v_idx) - pnode) / J;
            dofs = linsolve(Phi, [u; v; theta]);
            
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