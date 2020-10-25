%%% Same as SB3D2_test.m, but uses the y_orientation property such that the beam rotates 90-degrees
%%% about the longitudinal axis, which leads to purely weak-axis bending. The result produced here
%%% matches the analytical solution for the maximumum local deflection of 2.5812 cm exactly.

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
x = [75; 0; -75];
y = [100; 0; -100];
z = [-300; 0; 300];
nodes = table(ID, x, y, z);
clear ID x y z

%// element connectivity
ID = [1; 2];
n1 = [1; 2];
n2 = [2; 3];
elements = table(ID, n1, n2);
clear ID n1 n2

%// element properties
E = 20e+03; % kN/cm/cm, Young's modulus
nu = 0.3; % Poisson's ratio
A = 720; % cm^2, cross-sectional area
Iyy = 19.44e+03; %cm^4, moment of inertia about elastic neutral y-axis
Izz = 96e+03; % cm^4, moment of inertia about elastic neutral z-axis
J = 290.4e+03; % cm^4, polar moment of inertia
kappa = 10 * (1 + nu) / (12 + 11 * nu); % Timoshenko shear coefficient (rectangles)
local_y = -1 / 65 * [36, 48, 25]; % unit vector in global coordinates definining local y-axis 

%// force data, Fx, Fy, Fz, Mx, My, Mz, x, y, z
P = -175; % kN
force_data = [P * 4 / 5, -P * 3 / 5, 0, 0, 0, 0, nodes{2,2:4}];

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 1, 0, 0, 0, nodes{1,2:4};
                1, 1, 1, 0, 0, 0, nodes{3,2:4}];

            
%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements, 2);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof);

%// compute Timoshenko beam local stiffness matrix
[k, k_idx] = computeSB3D2Stiffness(mesh, isActiveDof, E, nu, A, Iyy, Izz, J, kappa,...
                                   'y_orientation', local_y);

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, k_idx);

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, k_idx);

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);