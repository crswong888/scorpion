clear all
format longeng

Gauss2P = 1 / sqrt(3) ;
Weight2P = 1.0 ;

QP = [ -Gauss2P -Gauss2P ; Gauss2P -Gauss2P ; Gauss2P Gauss2P ; -Gauss2P Gauss2P ] ;
master = [ -1 -1 ; 1 -1 ; 1 1 ; -1 1 ] ;
node = [ 1 7 ; 3 2 ; 5 6 ; 4 9 ] ;

%// evaluate shape functions at QP
N = zeros(4,4) ;
for qp = 1:4
    for i = 1:4
        N(qp,i) = 1 / 4 * (1 + QP(qp,1) * master(i,1)) * (1 + QP(qp,2) * master(i,2)) ;
    end
end

%// build Jacobian at QP and compute the integral
JQP = zeros(2,2) ; Area = 0 ;
for qp = 1:4
    JQP(1,:) = -(1 - QP(qp,2)) * node(1,:) + (1 - QP(qp,2)) * node(2,:) + ...
               (1 + QP(qp,2)) * node(3,:) - (1 + QP(qp,2)) * node(4,:) ;
    JQP(2,:) = - (1 - QP(qp,1)) * node(1,:) - (1 + QP(qp,1)) * node(2,:) + ...
               (1 + QP(qp,1)) * node(3,:) + (1 - QP(qp,1)) * node(4,:) ;
    JQP = 1 / 4 * JQP ;         
    Area = Area + det(JQP) * Weight2P ;
end