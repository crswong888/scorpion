%%% Same as SB3D2_test.m, but uses the y_orientation property such that load is projected along the 
%%% beam's strong axis so that bending is about the weak axis - matches analytical solution exactly

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


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
E = 20e+03 * ones(2, 1);
nu = 0.3 * ones(2, 1);
A = 720 * ones(2, 1);
Iyy = 19.44e+03 * ones(2, 1);
Izz = 96e+03 * ones(2, 1);
J = 290.4e+03 * ones(2, 1);
kappa = 10 * (1 + nu) / (12 + 11 * nu) * ones(2, 1);
y_orientation = 1 / 49 * [-12, -18, -13] .* ones(2,1);
elements = table(ID, n1, n2, E, nu, A, Iyy, Izz, J, kappa, y_orientation);
clear ID n1 n2

%// force data, Fx, Fy, Fz, Mx, My, Mz, x, y, z
P = -125; % kN
force_data = [P * 3 / 7, -P * 2 / 7, 0, 0, 0, 0, nodes{2,2:4}];

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 1, 0, 0, 0, nodes{1,2:4};
                1, 1, 1, 0, 0, 0, nodes{3,2:4}];

            
%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store the number of dimensions and the number of dofs per node for more concise syntax
num_dims = length(nodes{1,:}) - 1;
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
[mesh, props] = generateMesh(nodes, elements, num_dims, 2);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, num_dims, isActiveDof);

%// compute Timoshenko beam local stiffness matrix
[k, k_idx] = computeSB3D2Stiffness(mesh, props, isActiveDof);

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(num_dofs, length(nodes{:,1}), {k_idx});

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, {k}, {k_idx});

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);