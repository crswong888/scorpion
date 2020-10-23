%%% Test for the SB2D2 Timoshenko plane frame element - matches analytical solution exactly

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 1]);

%// node table (coordinates in centimeters)
ID = [1; 2; 3];
x = [-350; 0; 350];
y = [0; 0; 0];
nodes = table(ID, x, y);
clear ID x y

%// element connectivity
ID = [1; 2];
n1 = [1; 2];
n2 = [2; 3];
E = 20e+03 * ones(2, 1);
nu = 0.3 * ones(2, 1);
A = 720 * ones(2, 1);
I = 96e+03 * ones(2, 1);
kappa = 10 * (1 + nu) / (12 + 11 * nu) * ones(2, 1);
elements = table(ID, n1, n2, E, nu, A, I, kappa);
clear ID n1 n2

%// force data, Fx, Fy, Mz, x, y
P = -125; % kN
force_data = [0, P, 0, nodes{2,2:3}];

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 0, nodes{1,2:3};
                1, 1, 0, nodes{3,2:3}];

            
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
[k, k_idx] = computeSB2D2Stiffness(mesh, props, isActiveDof);

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(num_dofs, length(nodes{:,1}), {k_idx});

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, {k}, {k_idx});

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);