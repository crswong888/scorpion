%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Test for the RB3D2 rigid beam element - despite a 1,000,000 N force being applied at the midspan
%%% of a simple beam, no deflections occur.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath(genpath('functions'))


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 1, 1, 1, 1]);

%// node table (coordinates in centimeters)
ID = [1; 2; 3];
x = [100; 0; -100];
y = [150; 0; -150];
z = [-300; 0; 300];
nodes = table(ID, x, y, z);
clear ID x y z

%// element connectivity
ID = [1; 2];
n1 = [1; 2];
n2 = [2; 3];
elements = table(ID, n1, n2);
clear ID n1 n2

%// force data, Fx, Fy, Mz, x, y
P = -1e+03; % kN
force_data = [P * 3 / 7, -P * 2 / 7, 0, 0, 0, 0, nodes{2,2:4}];

%// input restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 1, 0, 0, 0, nodes{1,2:4};
                1, 1, 1, 0, 0, 0, nodes{3,2:4}];


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof);

%// compute rigid beam local stiffness matrix (if penalty not provided - default value assumed)
[k, k_idx] = computeRB3D2Stiffness(mesh, isActiveDof);

%// determine size of global system of equations and index offsets for active DOFs
[num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, k_idx);

%// assemble global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, k_idx);

%// assemble global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply boundary conditions and solve for displacements and reactions
[Q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);