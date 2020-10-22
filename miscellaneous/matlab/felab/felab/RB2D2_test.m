%%% Test for the RB2D2 rigid beam element

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 1]);

%// node table (coordinates in meters)
ID = [1; 2; 3];
x = [0; 2.5 * cos(pi / 4); 5.0 * cos(pi / 4)];
y = [0; 2.5 * sin(pi / 4); 5.0 * sin(pi / 4)];
nodes = table(ID, x, y);
clear ID x y

%// element connectivity
ID = [1; 2];
n1 = [1; 2];
n2 = [2; 3];
elements = table(ID, n1, n2);
clear ID n1 n2

%// force data, Fx, Fy, Mz, x, y
P = 1e+06; % Newtons
force_data = [P * cos(7 * pi / 4), P * sin(7 * pi / 4), 0, 5.0 * cos(pi / 4), 5.0 * sin(pi / 4)];

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 1, 0, 0];


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store the number of dimensions and the number of dofs per node for more concise syntax
num_dims = length(nodes{1,:}) - 1;
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements, 2, 2);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, num_dims, isActiveDof);

%// compute rigid beam local stiffness matrix (if penalty not provided - default value assumed)
[k, k_idx] = computeRB2D2Stiffness(mesh, isActiveDof);

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(num_dofs, length(nodes{:,1}), {k_idx});

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, {k}, {k_idx});

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);