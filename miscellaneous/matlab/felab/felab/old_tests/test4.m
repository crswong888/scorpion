%%% TEST 4: Generate Stiffness Matrix of C3D8 Element

clear all
format longeng
fprintf('\n')

addpath('../functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

% NOTE: csv files with mesh discretization or BC information must (and should) have column headers
% but they need not match the ones shown here, leave first row blank if nothing else

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 1, 0, 0, 0]);

%// node table
ID = [1; 2; 3; 4; 5; 6; 7; 8];
x = [0; 1; 1; 0; 0; 1; 1; 0];
y = [0; 0; 1; 1; 0; 0; 1; 1];
z = [0; 0; 0; 0; 1; 1; 1; 1];
nodes = table(ID, x, y, z);
clear ID x y z

%// element connectivity and properties table
ID = 1; 
n1 = 1; n2 = 2; n3 = 3; n4 = 4; n5 = 5; n6 = 6; n7 = 7; n8 = 8;
E = 200e+09; % Pa, Young's modulus of steel
nu = 0.3; % Poisson's Ratio of steel
elements = table(ID, n1, n2, n3, n4, n5, n6, n7, n8, E, nu);
clear ID n1 n2 n3 n4 n5 n6 n7 n8


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// convert element-node connectivity info and properties to numeric arrays
[mesh, props] = generateMesh(nodes, elements, 3, 8);

%// compute plane stress QUAD4 element local stiffness matrix
[k, k_idx] = computeC3D8Stiffness(mesh, props, isActiveDof);