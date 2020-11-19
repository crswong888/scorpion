%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% This is a model of a cantilvered Euler-Bernoulli beam with a two-cycle sinusoidal load along its
%%% length. There are some discrepancies between the analytical solution and the one produced here,
%%% however, they are nearly the same. The theoretical max deflection at the free end is 2.513 cm,
%%% which is what is obtained here by resolving the DOFs into its strictly transverse componenent,
%%% i.e., by running '[12 / 13, -5 / 13] * Q(4:5)'. The interpolated displacements between nodes are
%%% nearly exact. Small discrepencies aren't surprising, since the FEM is primarily based on
%%% polynomial approximations, modelling transcendentals should produce small errors. One clear
%%% error is the reactions - since the sine wave completes exactly 2 cycles from one end of the beam
%%% to the other, the net force should be zero, and therefore, so should the reaction at the fixed
%%% end. However, there seems to be a small residual value. Ensuring that these minor errors aren't
%%% attributable to this code, but, rather, to the FEM itself, needs to be addressed in the future.

clear all %#ok<CLALL>
format longeng
fprintf('\n')

addpath(genpath('functions'))


%%% INPUT PARAMETERS
%%% ------------------------------------------------------------------------------------------------

%// input boolean of active degrees of freedom, dof = ux, uy, uz, rx, ry, rz
isActiveDof = logical([1, 1, 0, 0, 0, 1]);

%// node table (coordinates in centimeters)
ID = [1; 2];
x = [-125; 125];
y = [-300; 300];
nodes = table(ID, x, y);
clear ID x y

%// element connectivity
ID = 1;
n1 = 1;
n2 = 2;
elements = table(ID, n1, n2);
clear ID n1 n2

%// element properties
E = 20e+03; % kN/cm/cm, Young's modulus
A = 720; % cm^2, cross-sectional area
I = 96e+03; % cm^4, second moment of area

%// force data, Fx, Fy, Mz, x, y
W = @(x) sin(2 * pi * (x + 325) / 325); % kN/cm, 2-cycle sinusoidal loading function on [-325, 325]
force_data = distributeBeamForce(nodes, elements, 1, W);

%// input the restrained dof data = logical and coordinates (release = 0, restrain = 1)
support_data = [1, 1, 1, nodes{1,2:3}];


%%% SOURCE COMPUTATIONS
%%% ------------------------------------------------------------------------------------------------

%// store number of dofs per node for more concise syntax
num_dofs = length(isActiveDof(isActiveDof));

%// convert element-node connectivity info and properties to numeric arrays
mesh = generateMesh(nodes, elements);

%// generate tables storing nodal forces and restraints
[forces, supports] = generateBCs(nodes, force_data, support_data, isActiveDof);

%// compute beam local stiffness matrix
[k, k_idx] = computeB2D2Stiffness(mesh, isActiveDof, E, A, I);

%// determine wether a global dof is truly active based on element stiffness contributions
[num_eqns, real_idx_diff] = checkActiveDofIndex(nodes, num_dofs, k_idx);

%// assemble global stiffness matrix
K = assembleGlobalStiffness(num_eqns, real_idx_diff, k, k_idx);

%// assemble global force vector
F = assembleGlobalForce(num_dofs, num_eqns, real_idx_diff, forces);

%// apply boundary conditions and solve for the displacements and reactions
[Q, R] = systemSolve(num_dofs, num_eqns, real_idx_diff, supports, K, F);


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

render2DSolution(nodes, mesh, 'B2D2', num_dofs, real_idx_diff, Q, 'Style', 'wireframe',...
                 'ScaleFactor', 25, 'SamplesPerEdge', 12, 'Ghost', true, 'BeamForceElementID', 1,... 
                 'BeamForce', W, 'FlexRigidity', E * I)