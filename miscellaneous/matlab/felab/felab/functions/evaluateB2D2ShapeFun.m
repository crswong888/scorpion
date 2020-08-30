function [N, dN, H, d2H] = evaluateB2D2ShapeFun(xi)
    
    %// evaluate the 1x2 array of Lagrange shape functions at the natural coordinate
    N = 1 / 2 * [1 - xi, 1 + xi]; % Lagrange shape functions used for spatial interpolation
    %/ evaluate the derivative of Lagrange shape functions
    dN = 1 / 2 * [-1, 1];

    %// evaluate the 1x4 array of Hermite shape functions at the natural coordinate 
    H = []; % TODO
    %/ evaluate the 2nd derivative of Hermite shape functions
    d2H = [3 / 2 * xi, (-1 + 3 * xi) / 2, -3 / 2 * xi, (1 + 3 * xi) / 2];

end