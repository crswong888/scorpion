%%% Example 4.1 from Chandrupatla, "Introduction to Finite Elements in Engineering, 2nd edition"
%%% This solves a plane truss structure subject to concentrated forces at the joints.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 0]);

%// node table (coordinates in inches)
ID = [1; 2; 3; 4];
x = [0; 40; 40; 0];
y = [0; 0; 30; 30];
nodes = table(ID, x, y);
clear ID x y

%// element connectivity and properties table
ID = [1; 2; 3; 4];
n1 = [1; 3; 1; 4];
n2 = [2; 2; 3; 3];
E = 29.5e+06 * ones(length(ID), 1); % psi
A = 1.0 * ones(length(ID), 1); % sq-in
elements = table(ID, n1, n2, E, A);
clear ID n1 n2

%// force data, Fx, Fy, x, y
force_data = [20e+03, 0, nodes{2,2:3};
              0, -25.0e+03, nodes{3,2:3}]; % forces in lb

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, nodes{1,2:3};
                0, 1, nodes{2,2:3};
                1, 1, nodes{4,2:3}];

                
%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dimensions and number of dofs per node for more concise syntax
num_dims = length(nodes{1,:}) - 1;
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
[mesh, props] = generateMesh(nodes, elements, num_dims, 2);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, num_dims, isActiveDof);

%// compute truss element local stiffness matrix
[k, k_idx] = computeT2D2Stiffness(mesh, props, isActiveDof);

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(num_dofs, length(nodes{:,1}), {k_idx});

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, {k}, {k_idx});

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);