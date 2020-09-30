clear all %#ok<CLALL>
format longeng
fprintf("\n")

%%% NOTE: "Any point in space can be considered as the master node for static loading; however, for
%%% dynamic analysis, the master node must be at the center of the mass if we wish to restrict our
%%% fomulation to a diagonal mass matrix." --SAP2000 manual


%%% DERIVE RB2D2 (SAP FORMULATION) FOR REFERENCE
%%% ------------------------------------------------------------------------------------------------

syms C
x = sym('x', [2 1]);
y = sym('y', [2 1]);

%// compute beam element longitudinal axis vector
dx = x(2) - x(1); 
dy = y(2) - y(1);

%// compute 2D constraint coefficient matrix (enforces strains to be 0)
B2 = [1, 0, -dy, -1,  0,  0;
      0, 1,  dx,  0, -1,  0;
      0, 0,   1,  0,  0, -1];
  
%// compute 2D rigid stiffness matrix
K2 = C * transpose(B2) * B2;

%// check if 2D stiffness matrix is symmetric (true if a matrix A equals its nonconjugate tranpose)
isK2symmetric = isequal(K2, transpose(K2));


%%% DERIVE RB3D2 (SAP FORMULATION)
%%% ------------------------------------------------------------------------------------------------

z = sym('z', [2 1]);

%// compute z-component of the beam element longitudinal axis vector
dz = z(2) - z(1);

%// compute constraint coefficient matrix (enforces strains to be 0)
B = [1, 0, 0,   0,  dz, -dy, -1,  0,  0,  0,  0,  0;
     0, 1, 0, -dz,   0,  dx,  0, -1,  0,  0,  0,  0;
     0, 0, 1,  dy, -dx,   0,  0,  0, -1,  0,  0,  0;
     0, 0, 0,   1,   0,   0,  0,  0,  0, -1,  0,  0;
     0, 0, 0,   0,   1,   0,  0,  0,  0,  0, -1,  0;
     0, 0, 0,   0,   0,   1,  0,  0,  0,  0,  0, -1];

%// compute rigid stiffness matrix
K = C * transpose(B) * B;

%// check if stiffness matrix is symmetric (true if a matrix A equals its nonconjugate tranpose)
isKsymmetric = isequal(K, transpose(K));