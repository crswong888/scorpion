%%% TEST 5: HEX8 Model of a Fixed-Fixed, Slender Beam

clear all
format longeng
fprintf('\n')

addpath('../functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 1, 0, 0, 0]);

%// input the mesh discretization parameters
Lx = 5; Nx = 100; Ly = 0.4; Ny = 8; Lz = 0.1616; Nz = 3;

%// inpute mesh material properties
E = 200e+09; % Pa, Young's modulus of steel
nu = 0.3; % Poisson's Ratio of steel


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// generate a QUAD4 mesh for a simple, rectangular domain
[nodes, elements] = createRectilinearMesh('HEX8',...
    'Lx', Lx, 'Nx', Nx, 'Ly', Ly, 'Ny', Ny, 'Lz', Lz, 'Nz', Nz, 'E', E, 'nu', nu);

