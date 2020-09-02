%%% This is a nominal control test that uses the tradition T2D2 element for comparison to R2D2.

clear all
format longeng
fprintf('\n') % Command Window output formatting

addpath('functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 0]);

%// node table (coordinates in inches)
ID = [1; 2; 3];
x = [0; 120; 60];
y = [0; 0; 120];
nodes = table(ID, x, y);
clear ID x y

%// element connectivity
ID = [1; 2];
n1 = [1; 3];
n2 = [3; 2];
E = 29.5e+06 * ones(length(ID), 1); % psi
A = 1.0 * ones(length(ID), 1); % sq-in
elements = table(ID, n1, n2, E, A);
clear ID n1 n2

%// force data, Fx, Fy, Mz, x, y
force_data = [0, -1e+06, 0, 60, 120]; % forces in lb

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 0, 0, 0;
                1, 1, 0, 120, 0];

            
%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// convert element-node connectivity info and properties to numeric arrays
[mesh, props] = generateMesh(nodes, elements, 2, 2);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data);

%// compute link element local stiffness matrix (default oenalty is 1e+08 for all elements)
[k, k_idx] = computeT2D2Stiffness(mesh, props, isActiveDof);

%// store the number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(num_dofs, length(nodes{:,1}), {k_idx});

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, {k}, {k_idx});

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);