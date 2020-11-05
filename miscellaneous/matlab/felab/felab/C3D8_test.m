%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Problem 9.1 from Chandrupatla, "Introduction to Finite Elements in Engineering, 2nd edition"
%%% This models a cantilevered steel plates subject to a concentrated force at a top corner of the
%%% free end face. The results for the deflections and reactions match those given in the solution
%%% manual which could be found online at:
%%%
%%% ```https://www.studocu.com/en-ca/document/the-university-of-british-columbia/advanced-ship-struc
%%%    tures/other/solution-manual-for-introduction-to-finite-elements-in-engineering-4th-edition/38
%%%    24327/view````

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath(genpath('functions'))


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 1, 0, 0, 0]);

%// input the mesh discretization parameters (length in inches)
Lx = 20; Nx = 3; Ly = 2.5; Ny = 1; Lz = 0.5; Nz = 1;

%// element properties
E = 30e+06; % psi, Young's modulus
nu = 0.3; % Poisson's Ratio

%// generate a HEX8 mesh
[nodes, elements] = createRectilinearMesh('HEX8',...
    'Lx', Lx, 'Nx', Nx, 'Ly', Ly, 'Ny', Ny, 'Lz', Lz, 'Nz', Nz);

%// input concentrated force data
P = 600; % lb
force_data = [0, 0, -P, 20, 0, 0.5];

%// input restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 1, 0, 0, 0;
                1, 1, 1, 0, 2.5, 0;
                1, 1, 1, 0, 0, 0.5;
                1, 1, 1, 0, 2.5, 0.5];


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof);

%// compute plane stress QUAD4 element local stiffness matrix
[k, k_idx] = computeC3D8Stiffness(mesh, isActiveDof, E, nu);

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, k_idx);

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, k_idx);

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[Q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);