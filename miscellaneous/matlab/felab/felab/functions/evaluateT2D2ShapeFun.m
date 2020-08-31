function [N, dN] = evaluateT2D2ShapeFun(xi)

    %// evaluate the 1x2 array of Lagrange shape functions at the natural coordinate
    N = 1 / 2 * [1 - xi, 1 + xi]; % Lagrange shape functions used for spatial interpolation
    
    %/ evaluate the derivative of Lagrange shape functions
    dN = 1 / 2 * [-1, 1];

end