%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [H, dH, d2H] = evaluateHermiteShapeFun(xi, J)
    %// evaluate Hermite shape functions at natural coordinate 
    H = 1 / 4 * [2 - 3 * xi + xi^3,...
                 J * (1 - xi - xi^2 + xi^3),...
                 2 + 3 * xi - xi^3,...
                 J * (-1 - xi + xi^2 + xi^3)];
    
    %// evaluate their derivatives
    dH = 1 / 4 * [-3 + 3 * xi^2,...
                  J * (-1 - 2 * xi + 3 * xi^2),... 
                  3 - 3 * xi^2,...
                  J * (-1 + 2 * xi + 3 * xi^2)];
             
    %// evaluate their second derivatives
    d2H = 1 / 2 * [3 * xi,...
                   J * (-1 + 3 * xi),... 
                   -3 * xi,...
                   J * (1 + 3 * xi)];
end