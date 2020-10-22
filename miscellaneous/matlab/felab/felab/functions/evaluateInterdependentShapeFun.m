function [H, dH] = evaluateInterdependentShapeFun(xi, J, Omega, component)
    %// parse 'component' input controlling which component of the IIE shape function is desired
    params = inputParser;
    addRequired(params, 'component', @(x) any(validatestring(x, {'uy', 'uz', 'ry', 'rz'})))
    parse(params, component);

    %// transverse deflection along y
    if (strcmp(component, 'uy'))
        %/ evaluate interdependent interpolation shape functions at natural coordinate
        H = 1 / (4 * J^2 + 12 * Omega)...
            * [2 * J^2 + 6 * Omega - 3 * J^2 * xi - 6 * Omega * xi + J^2 * xi^3,...
               J^3 + 3 * Omega * J - J^3 * xi - J^3 * xi^2 - 3 * Omega * J * xi^2 + J^3 * xi^3,...
               2 * J^2 + 6 * Omega + 3 * J^2 * xi + 6 * Omega * xi - J^2 * xi^3,...
               -J^3 - 3 * Omega * J - J^3 * xi + J^3 * xi^2 + 3 * Omega * J * xi^2 + J^3 * xi^3];
        
        %/ evaluate their derivatives
        dH = 1 / (4 * J^2 + 12 * Omega)...
             * [-3 * J^2 - 6 * Omega + 3 * J^2 * xi^2,...
                -J^3 - 2 * J^3 * xi - 6 * Omega * J * xi + 3 * J^3 * xi^2,...
                3 * J^2 + 6 * Omega - 3 * J^2 * xi^2,...
                -J^3 + 2 * J^3 * xi + 6 * Omega * J * xi + 3 * J^3 * xi^2];
    
    %// transverse deflection along z
    elseif (strcmp(component, 'uz'))
        %/ evaluate interdependent interpolation shape functions at natural coordinate
        H = 1 / (4 * J^2 + 12 * Omega)...
            * [2 * J^2 + 6 * Omega - 3 * J^2 * xi - 6 * Omega * xi + J^2 * xi^3,...
               -J^3 - 3 * Omega * J + J^3 * xi + J^3 * xi^2 + 3 * Omega * J * xi^2 - J^3 * xi^3,...
               2 * J^2 + 6 * Omega + 3 * J^2 * xi + 6 * Omega * xi - J^2 * xi^3,...
               J^3 + 3 * Omega * J + J^3 * xi - J^3 * xi^2 - 3 * Omega * J * xi^2 - J^3 * xi^3];
        
        %/ evaluate their derivatives
        dH = 1 / (4 * J^2 + 12 * Omega)...
             * [-3 * J^2 - 6 * Omega + 3 * J^2 * xi^2,...
                J^3 + 2 * J^3 * xi + 6 * Omega * J * xi - 3 * J^3 * xi^2,...
                3 * J^2 + 6 * Omega - 3 * J^2 * xi^2,...
                J^3 - 2 * J^3 * xi - 6 * Omega * J * xi - 3 * J^3 * xi^2];
    
    %// bending about y
    elseif (strcmp(component, 'ry'))
        %/ evaluate interdependent interpolation shape functions at natural coordinate
        H = 1 / (4 * J^2 + 12 * Omega)...
            * [3 * J - 3 * J * xi^2,...
               -J^2 + 6 * Omega - 2 * J^2 * xi - 6 * Omega * xi + 3 * J^2 * xi^2,...
               -3 * J + 3 * J * xi^2,...
               -J^2 + 6 * Omega + 2 * J^2 * xi + 6 * Omega * xi + 3 * J^2 * xi^2];
        
        %/ evaluate their derivatives
        dH = 1 / (2 * J^2 + 6 * Omega)...
             * [-3 * J * xi,...
                -J^2 - 3 * Omega + 3 * J^2 * xi,...
                3 * J * xi,...
                J^2 + 3 * Omega + 3 * J^2 * xi];
    
    %// bending about z
    else
        %/ evaluate interdependent interpolation shape functions at natural coordinate
        H = 1 / (4 * J^2 + 12 * Omega)...
            * [-3 * J + 3 * J * xi^2,...
               -J^2 + 6 * Omega - 2 * J^2 * xi - 6 * Omega * xi + 3 * J^2 * xi^2,...
               3 * J - 3 * J * xi^2,...
               -J^2 + 6 * Omega + 2 * J^2 * xi + 6 * Omega * xi + 3 * J^2 * xi^2];
        
        %/ evaluate their derivatives
        dH = 1 / (2 * J^2 + 6 * Omega)...
             * [3 * J * xi,...
                -J^2 - 3 * Omega + 3 * J^2 * xi,...
                -3 * J * xi,...
                J^2 + 3 * Omega + 3 * J^2 * xi];
    end
end