function [N, dN] = evaluateC3D8ShapeFun(xi, eta, zeta)  
    %// Use signs of nodal natural coordinates to evaluate shape funcs in a simple condensed format
    %/ nodal coordinates of master element n1, n2, n3, n4, n5, n6, n7, n8
    master = [-1 -1 -1; 1 -1 -1; 1 1 -1; -1 1 -1; -1 -1 1; 1 -1 1; 1 1 1; -1 1 1];  
    N = zeros(1,8); dN = zeros(3,8); % initialize
    for i = 1:8
        %/ evaluate 1x8 array of Lagrange shape functions at the natural coordinate
        N(i) = (1 + xi * master(i,1)) * (1 + eta * master(i,2)) * (1 + zeta * master(i,3));
        %/ evaluate 3x8 array of shape function partial derivatives WRT natural coordinates
        dN(1,i) = master(i,1) * (1 + eta * master(i,2)) * (1 + zeta * master(i,3)); % 8 * dN/dxi
        dN(2,i) = (1 + xi * master(i,1)) * master(i,2) * (1 + zeta * master(i,3)); % 8 * dN/deta
        dN(3,i) = (1 + xi * master(i,1)) * (1 + eta * master(i,2)) * master(i,3); % 8 * dN / dzeta
    end, N = N / 8; dN = dN / 8;
end