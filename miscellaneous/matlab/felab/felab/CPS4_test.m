%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Test for CPS4 constant plane stress quadrilateral. The model is of a Fixed-Fixed, Slender Column 
%%% with a lateral concentrated force at its center. The columns cross-sectional dimensions relative 
%%% to its length are small and loading is transverse so a plane stress formulation is appropriate
%%%
%%% The max deflections in accordance with Euler-Bernoulli and Timoshenko Beam theories are 
%%% 0.6104e-03 m and 0.6582e-03 m, respectively. The max deflection computed here is 0.6510e-03 m
%%% and so the model lines up with the theory.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath(genpath('functions'))


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 0]);

%// input mesh discretization parameters
Lx = 0.2; Nx = 8; Ly = 2.5; Ny = 100;

%// element properties
E = 200e+06; % kPa, Young's modulus of steel
nu = 0.3; % Poisson's Ratio of steel
t = 0.1; % m, thickness of cross-section

%// generate a QUAD4 mesh
[nodes, elements] = createRectilinearMesh('QUAD4', 'Lx', Lx, 'Nx', Nx, 'Ly', Ly, 'Ny', Ny);

%// input concentrated force data = dof magnitude and coordinates
P = 100; % kN, concentrated force to be distributed along midspan nodeset
force_data = zeros(Nx + 1, 4);
force_data(1,1) = P / Nx / 2; 
force_data(end,1) = force_data(1,1);
force_data(2:(end - 1),1) = P / Nx;
force_data(:,4) = Ly / 2;
for i = 2:(Nx + 1) 
    force_data(i,3) = force_data((i - 1),3) + Lx / Nx; 
end

%// input restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = zeros(2 * Nx + 2, 4);
support_data(:,1:2) = 1;
support_data((Nx + 2):end,4) = Ly;
for i = 2:(Nx + 1)
    support_data(i,3) = support_data((i - 1),3) + Lx / Nx; 
end
support_data((Nx + 2):end,3) = support_data(1:(Nx + 1),3);

             
%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof);

%// compute plane stress QUAD4 element local stiffness matrix
[k, k_idx] = computeCPS4Stiffness(mesh, isActiveDof, E, nu, t);

%// determine size of global system of equations and index offsets for active DOFs
[num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, k_idx);

%// assemble global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, k_idx);

%// assemble global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply boundary conditions and solve for displacements and reactions
[Q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

render2DSolution(nodes, mesh, 'CPS4', num_dofs, real_idx_diff, Q, 'ScaleFactor', 125, 'Ghost', true)