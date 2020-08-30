clear all
format longeng

%// 2-point Gauss rule quadrature points
Gauss2P = 1 / sqrt(3) ; Weight2P = 1.0 ;
QP = [ -Gauss2P -Gauss2P ; Gauss2P -Gauss2P ; Gauss2P Gauss2P ; -Gauss2P Gauss2P ] ;
node = [ 0 0 ; 2 0 ; 2 1 ; 0 1 ; 1 0.2 ; 2.2 0.5 ; 1 1.2 ; 0.2 0.5 ] ;

%// elasticity properties
E = 96 ; nu = 1 / 3 ;

%// shape functions in natural coordinate system
N = zeros(length(QP),8) ;
for qp = 1:length(QP)
    xi = QP(qp,1) ; eta = QP(qp,2) ;
    
    N(qp,1) = -(1 - xi) * (1 - eta) * (1 + xi + eta) / 4 ;
    N(qp,2) = -(1 + xi) * (1 - eta) * (1 - xi + eta) / 4 ;
    N(qp,3) = -(1 + xi) * (1 + eta) * (1 - xi - eta) / 4 ;
    N(qp,4) = -(1 - xi) * (1 + eta) * (1 + xi - eta) / 4 ;
    N(qp,5) = (1 - xi * xi) * (1 - eta) / 2 ;
    N(qp,6) = (1 + xi) * (1 - eta * eta) / 2 ;
    N(qp,7) = (1 - xi * xi) * (1 + eta) / 2 ;
    N(qp,8) = (1 - xi) * (1 - eta * eta) / 2 ;
end

%// shape function derivative WRT to natural coordinates
dN = zeros(2,8,length(QP)) ;
for qp = 1:length(QP)
    xi = QP(qp,1) ; eta = QP(qp,2) ;
    
    dN(1,:,qp) = [ -(2 * xi + eta) * (eta - 1), -(2 * xi - eta) * (eta - 1), ...
                   (2 * xi + eta) * (eta + 1), (2 * xi - eta) * (eta + 1), ...
                   xi * (eta - 1), -0.5 * (eta * eta - 1), ...
                   -xi * (eta + 1), 0.5 * (eta * eta - 1) ] ;
               
    dN(2,:,qp) = [ -(xi + 2 * eta) * (xi - 1), -(xi - 2 * eta) * (xi + 1), ...
                    (xi + 2 * eta) * (xi + 1), (xi - 2 * eta) * (xi - 1), ...
                    0.5 * (xi * xi - 1), -(xi + 1) * eta, ...
                    -0.5 * (xi * xi - 1), (xi - 1) * eta ] ;
end
dN(:,1:4,:) = dN(:,1:4,:) / 4 ;

%// coordinate transform/element mapping parameters
dxdxi = zeros(2,2,length(QP)) ;
J = zeros(length(QP),1) ; dNdx = zeros(2,8,length(QP)) ;
for qp = 1:length(QP)
    dxdxi(:,:,qp) = dN(:,:,qp) * node ;
    J(qp) = det(dxdxi(:,:,qp)) ;
    dNdx(:,:,qp) = linsolve(dxdxi(:,:,qp), dN(:,:,qp)) ;
end

%// strain-displacement relationship
B = zeros(4,16,length(QP)) ;
for qp = 1:length(QP)
    B(1,:,qp) = [ dNdx(1,1,qp), 0, dNdx(1,2,qp), 0, dNdx(1,3,qp), 0, dNdx(1,4,qp), 0, ...
                  dNdx(1,5,qp), 0, dNdx(1,6,qp), 0, dNdx(1,7,qp), 0, dNdx(1,8,qp), 0 ] ;
                  
    B(2,:,qp) = [ 0, dNdx(2,1,qp), 0, dNdx(2,2,qp), 0, dNdx(2,3,qp), 0, dNdx(2,4,qp), ...
                  0, dNdx(2,5,qp), 0, dNdx(2,6,qp), 0, dNdx(2,7,qp), 0, dNdx(2,8,qp) ] ; 
                  
    B(3,:,qp) = zeros(1,16) ; % zero row for the strain_zz component (plane strain)
    
    B(4,:,qp) = [ dNdx(2,1,qp), dNdx(1,1,qp), dNdx(2,2,qp), dNdx(1,2,qp), ...
                  dNdx(2,3,qp), dNdx(1,3,qp), dNdx(2,4,qp), dNdx(1,4,qp), ...
                  dNdx(2,5,qp), dNdx(1,5,qp), dNdx(2,6,qp), dNdx(1,6,qp), ...
                  dNdx(2,7,qp), dNdx(1,7,qp), dNdx(2,8,qp), dNdx(1,8,qp) ] ;
end

%// stress-plane strain compatibility
lambda = E * nu / ((1 + nu) * (1 - 2 * nu)) ; % Lame's first constant
D = lambda / nu * [ 1 - nu,     nu, 0,                0 ;
                        nu, 1 - nu, 0,                0 ;
                        nu,     nu, 0,                0 ;
                         0,      0, 0, (1 - 2 * nu) / 2 ] ;

%// element stiffness matrix
A = zeros(16,16) ;
for qp = 1:length(QP)
    c = J(qp) * Weight2P ;
    A = A + c * transpose(B(:,:,qp)) * D * B(:,:,qp) ;
end