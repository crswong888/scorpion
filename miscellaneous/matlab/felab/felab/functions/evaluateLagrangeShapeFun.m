function [N, dN] = evaluateLagrangeShapeFun(xi)
    %// evaluate Lagrange shape functions at natural coordinate
    N = 1 / 2 * [1 - xi, 1 + xi];
    
    %// evaluate their derivatives
    dN = 1 / 2 * [-1, 1];
end