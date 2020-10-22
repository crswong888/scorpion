function [H, d2H] = evaluateHermiteShapeFun(xi)
    %// evaluate Hermite shape functions at natural coordinate 
    H = 1 / 4 * [2 - 3 * xi + xi^3, 1 - xi - xi^2 + xi^3, 2 + 3 * xi - xi^3, -1 - xi + xi^2 + xi^3];
    
    %// evaluate their 2nd derivatives
    d2H = 1 / 2 * [3 * xi, -1 + 3 * xi, -3 * xi, 1 + 3 * xi];
end