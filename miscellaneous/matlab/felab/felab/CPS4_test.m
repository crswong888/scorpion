%%% Model of a Fixed-Fixed, Slender Beam with a point load at its center using CPS4 elements
%%% The beams cross-sectional dimension relative to its length are small and loading is transverse
%%% so a plane stress formulation is appropriate
%%%
%%% The max deflections in accordance with Euler-Bernoulli and Timoshenko Beam theories are 
%%% 0.6104e-03 m and 0.6582e-03 m, respectively. The max deflection computed here is 0.6510e-03 m
%%% and so the model lines up with the theory.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath('functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 0]);

%// input mesh discretization parameters
Lx = 2.5; Nx = 100; Ly = 0.2; Ny = 8;

%// element properties
E = 200e+06; % kPa, Young's modulus of steel
nu = 0.3; % Poisson's Ratio of steel
t = 0.1; % m, thickness of cross-section

%// generate a QUAD4 mesh
[nodes, elements] = createRectilinearMesh('QUAD4', 'Lx', Lx, 'Nx', Nx, 'Ly', Ly, 'Ny', Ny);

%// input concentrated force data = dof magnitude and coordinates
P = -100; % kN, the concentrated force to be distributed along the nodeset
force_data = zeros(Ny+1,4);
force_data(1,2) = P / Ny / 2; force_data(end,2) = force_data(1,2);
force_data(2:end-1,2) = P / Ny;
force_data(:,3) = Lx / 2;
for i = 2:(Ny+1), force_data(i,4) = force_data(i-1,4) + Ly / Ny; end

%// input restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = zeros(2*Ny+2,4);
support_data(:,1:2) = 1;
support_data(Ny+2:end,3) = Lx;
for i = 2:(Ny + 1), support_data(i,4) = support_data(i-1,4) + Ly / Ny; end
support_data(Ny+2:end,4) = support_data(1:Ny+1,4);

             
%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements, 4);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof);

%// compute plane stress QUAD4 element local stiffness matrix
[k, k_idx] = computeCPS4Stiffness(mesh, isActiveDof, E, nu, t);

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, k_idx);

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, k_idx);

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

%// deflection along length of beam
plot(q((2:2:202)-transpose(real_idx_diff(2:2:202))))