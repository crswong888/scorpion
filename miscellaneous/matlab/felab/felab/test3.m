%%% TEST 3: QUAD4 Model of a Simply Supported, Slender Beam

clear all
format longeng
fprintf('\n') % Command Window output formatting

addpath('functions')


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([ 1, 1, 0, 0, 0, 1 ]) ;

%// input the mesh discretization parameters
Lx = 3.0 ; Nx = 120 ; Ly = 0.25 ; Ny = 10 ;

%// inpute mesh material properties
E = 200e+06 ; % kPa, Young's modulus of steel
nu = 0.3 ; % Poisson's Ratio of steel
t = 0.1 ; % m, thickness of cross-section

%// input the distributed point force data = dof magnitude and coordinates
P = -75 ; % kN, the concentrated force to be distributed along the nodeset
force_data = zeros(Ny+1,5) ;
force_data(1,2) = P / Ny / 2 ; force_data(end,2) = force_data(1,2) ;
force_data(2:end-1,2) = P / Ny ;
force_data(:,4) = Lx / 2 ;
for i = 2:(Ny+1), force_data(i,5) = force_data(i-1,5) + Ly / Ny ; end

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [ 1, 1, 0, 0.0, Ly / 2 ;
                 1, 1, 0,  Lx, Ly / 2 ] ;
               
%// input the rigid beam constraint data = master and slave nodal coordinates
constraint_data = zeros(2*Ny,4) ;
constraint_data(Ny+1:end,1:2:3) = Lx ;
for i = 2:Ny, constraint_data(i,4) = constraint_data(i-1,4) + Ly / Ny ; end
constraint_data(Ny/2+1:Ny,4) = constraint_data(Ny/2+1:Ny,4) + Ly / Ny ;
constraint_data(Ny+1:end,4) = constraint_data(1:Ny,4) ;
constraint_data(1:Ny/2,2) = constraint_data(1:Ny/2,4) + Ly / Ny ;
constraint_data(Ny/2+1:Ny,2) = constraint_data(Ny/2+1:Ny,4) - Ly / Ny ;
constraint_data(Ny+1:end,2) = constraint_data(1:Ny,2) ;

%// input penalty coefficient to use for solving system of equations and enforcing constraints
penalty = 1e+04 ; % the element stiffnesses are already high in this case, so 10^4 should be safe

% NOTE: to plot the displacement, transverse displacement, run something like:
% plot(q((2:3:3*Nx+3)-transpose(real_idx_diff(2:3:3*Nx+3))))


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// generate a QUAD4 mesh for a simple, rectangular domain
[nodes, elements] = createRectilinearMesh('QUAD4',...
    'Lx', Lx, 'Nx', Nx, 'Ly', Ly, 'Ny', Ny, 'E', E, 'nu', nu, 't', t) ;

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data) ;
constraints = generateConstraints(nodes, constraint_data) ;
clear force_data support_data constraint_data

%// convert element-node connectivity info and properties to numeric arrays
[mesh, props] = generateMesh(nodes, elements, 2, 4) ;

%// compute plane stress QUAD4 element local stiffness matrix
[k, k_idx] = computeCPS4Stiffness(mesh, props, isActiveDof) ;

%// compute rigid beam element local stiffness matrix
% TODO: this actually isn't the max we want, we want the max from the
% global matrix that is assembled from only the QUAD4 part of the mesh
C = max(abs(k),[],'all') * penalty ; % determine penalty stiffness as max Kij times coefficient
[kc, kc_idx] = computeRB2D2Stiffness(constraints, nodes, C, isActiveDof) ;

%// store the number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof)) ;

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(num_dofs, length(nodes{:,1}), {k_idx, kc_idx}) ;

%// assemble the global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, {k, kc}, {k_idx, kc_idx}) ;

%// compute global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces) ;

%// apply the boundary conditions and solve for the displacements and reactions
[q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F) ;