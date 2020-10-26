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

%%% devel
Lx = 2.47371; Nx = 50; Ly = 0.2; Ny = 4;

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
mesh = generateMesh(nodes, elements);

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

%// 'reset(groot)' breaks 'DefaultFigurePosition', so store current default and manually reset
defaultFP = get(groot, 'DefaultFigurePosition');
set(groot, 'DefaultAxesPosition', [0.05, 0.05, 0.9, 0.9], 'DefaultFigureUnits', 'normalize', 'DefaultFigurePosition', [0.125, 0.25, 0.75, 0.75]);

%%% we would need some sort of of 3D equivalent for this with L, W, H
figure('Visible', 'off')
set(axes, 'Visible', 'off', 'Units', 'pixels')
ax = axes('Visible', 'off');
set(ax, 'Units', 'pixels');
resolution = [max(ax.Position(3:4)); min(ax.Position(3:4))];
close all

%%% might be simplere to use range() here, plus, I'm not even sure If im using min/max vals after
%%% this
num_nodes = length(nodes{:,1});
num_dims = length(nodes{1,2:end});

scale = 100;

displaced_nodes = zeros(num_nodes, num_dims);
for s = 1:num_dims
    for i = 1:num_nodes
        idx = num_dofs * (i - 1) + s;
        
        real_idx = idx - real_idx_diff(idx);
        
        displaced_nodes(i,s) = nodes{i,(s + 1)} + scale * q(real_idx);
    end
end

extents = zeros(num_dims, 4);
extents(:, 1) = 1:num_dims;
for s = 1:num_dims
    extents(s, 2) = min(displaced_nodes(:,s));
    extents(s, 3) = max(displaced_nodes(:,s));
end
extents(:,4) = extents(:,3) - extents(:,2);
extents = sortrows(extents, 4, 'descend');

%%% because of scaling, this whole fancy grid system concept is officially obsolete. Damn.
%%% what I can do is show "Real Displacements" in the contour plot and legend, and perhaps label the
%%% title appropriately. But the spatial coordinates will reflect values as if the displacements
%%% were actually those scaled values. Theres really no good way around this. It would have to be a
%%% very sophisticated grid system in order to label it properly.
%%% I suppose I could actually accomplish it, although I would need to draw the grid myself, and it 
%%% it would start at the points I've defined myself on the plot bounds, but then expand by some
%%% sort of function related to scale factor and displacements where coordinates are actually
%%% distorted

lowest = Inf;
for i = 10:20
    %/ some magnitude that is a multiple of 5 is best, 2 is okay, and 1 not best
    for m = [5, 2, 1]
        commdom = m * 10^(sign(log10(extents(1,4) / i)) * floor(abs(log10(extents(1,4) / i)) + 2));
        remainder = abs(extents(1,4) - round(extents(1,4) / i / commdom) * commdom * i);
        if (remainder < lowest)
            lowest = remainder;
            dx = round(extents(1,4) / i / commdom) * commdom;
            Nx = i;
        end
    end
end

offset = max(dx, abs((extents(1,4) .* resolution / resolution(1) - extents(:,4)) / 2));
limits(:,1) = extents(:,2) - round(offset / dx) * dx;
limits(:,2) = extents(:,3) + round(offset / dx) * dx;

grid = {(round(limits(1,1) / dx) * dx - 10 * dx):dx:(round(limits(1,2) / dx) * dx + 10 * dx);
        (round(limits(2,1) / dx) * dx - 10 * dx):dx:(round(limits(2,2) / dx) * dx + 10 * dx)};
    
%%% if ordering is not counterclockwise, this won't work.

figure(1);
plot(displaced_nodes(:,1), displaced_nodes(:,2), 'o', 'markerfacecolor', [0, 0, 0], 'markersize', 1.5) % probably won't even plot nodes


xticks(grid{1})
xlim(limits(1,:))
yticks(grid{2})
ylim(limits(2,:))
hold on




%// reset root graphics properties
reset(groot)
set(groot, 'DefaultFigurePosition', defaultFP);



% %/ aspect
% extents = [max(nodes(:,2)) - min(nodes(:,2)), max(nodes(:,3)) - min(nodes(:,3))];
% 
% resolution = 480e+03;
% width = sqrt(extents(1) * resolution / extents(2));
% if (width > 800)
%     resolution = 476.432e+03;
%     width = min(sqrt(extents(1) * resolution / extents(2)), 1024);
% end
% height = width * extents(2) / extents(1);




