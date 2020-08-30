function [N, dN] = evaluateCPS4ShapeFun(xi, eta)
    
    %// Use signs of nodal natural coordinates to evaluate shape funcs in a simple condensed format
    master = [ -1 -1 ; 1 -1 ; 1 1 ; -1 1 ] ; % nodal coordinates of master element n1, n2, n3, n4 
    N = zeros(1,4) ; dN = zeros(2,4) ; % initialize
    for i = 1:4
        %/ evaluate 1x4 array of Lagrange shape functions at the natural coordinate
        N(i) = 1 / 4 * (1 + xi * master(i,1)) * (1 + eta * master(i,2)) ;
        %/ evaluate 2x4 array of shape function partial derivatives WRT natural coordinates
        dN(1,i) = 1 / 4 * master(i,1) * (1 + eta * master(i,2)) ; % dN/dxi
        dN(2,i) = 1 / 4 * (1 + xi * master(i,1)) * master(i,2) ; % dN/deta
    end

end