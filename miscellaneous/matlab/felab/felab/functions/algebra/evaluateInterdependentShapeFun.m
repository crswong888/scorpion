%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [H, dH] = evaluateInterdependentShapeFun(xi, J, Omega, component)
    %// parse 'component' input controlling which component of the IIE shape function is desired
    params = inputParser;
    addRequired(params, 'component', @(x) any(validatestring(x, {'uy', 'uz', 'ry', 'rz'})))
    parse(params, component);

    %// cubic polynomials for transverse deflections
    if ((strcmp(component, 'uy')) || (strcmp(component, 'uz')))
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
        
        %/ functions for z-deflection component slightly different
        if (strcmp(component, 'uz'))
            H([1, 3]) = -H([1, 3]);
            dH([2, 4]) = -dH([2, 4]);
        end
    
    %// quadratic polynomials for bending
    else
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
        
        %/ functions for z-bending component slightly different
        if (strcmp(component, 'rz'))
            H([1, 3]) = -H([1, 3]);
            dH([2, 4]) = -dH([2, 4]);
        end
    end
end