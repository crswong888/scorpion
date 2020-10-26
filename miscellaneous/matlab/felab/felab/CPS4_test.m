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

%%% we would need some sort of of 3D equivalent for this with L, W, H - do 3D in separate function

%%% once all of the features are in the plot, e.g., colorbar, title, and axis labels, then we need
%%% to generate this test plot with all of those objects and finally get the axis resolution
figure('Visible', 'off', 'Units', 'normalize', 'Position', [0.125, 0.25, 0.75, 0.75])
ax = axes('Visible', 'off', 'Position', [0.05, 0.05, 0.9, 0.9]);
set(ax, 'Units', 'pixels');
resolution = [max(ax.Position(3:4)); min(ax.Position(3:4))];
close all

num_nodes = length(nodes{:,1});
num_dims = length(nodes{1,2:end});
num_blocks = 1;
num_local_nodes = 4; % length(ele_blk{b}{1,:}) / (num_dims + 1);
num_elems = length(mesh(:,1)); % length(ele_blk{b}{:,1});

ele_blk = {mesh};

% you can just put 0 here and get undisplaced mesh - default value will be 1
scale = 250;

displaced_nodes = zeros(num_nodes, num_dims);
disp_mag = zeros(num_nodes, 1);
for i = 1:num_nodes
    idx = num_dofs * (i - 1) + [1; 2];
    
    real_idx = idx - real_idx_diff(idx);
    
    displaced_nodes(i,:) = nodes{i,([1, 2] + 1)} + transpose(scale * q(real_idx));
    
    disp_mag(i) = norm(q(real_idx));
    
    
%     for s = 1:num_dims
%         idx = num_dofs * (i - 1) + s;
%         
%         real_idx = idx - real_idx_diff(idx);
%         
%         displaced_nodes(i,s) = nodes{i,(s + 1)} + scale * q(real_idx);
%     end
end

% % append dim ids to extents so if we swap x and y we know which is which
% extents = cat(1, transpose(1:2), transpose(range(displaced_nodes(:,1:2))));

%%% could've used range() here, but I need the min and max too for later calc, so keeping it
extents = zeros(num_dims, 4);
extents(:, 1) = 1:num_dims;
for s = 1:num_dims
    extents(s, 2) = min(displaced_nodes(:,s)); % min(nodes{:,(s + 1)});
    extents(s, 3) = max(displaced_nodes(:,s)); % max(nodes{:,(s + 1)});
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

%%% need to only do this max thing for y, otherwise, my assumptions here may be invalid. Plus, this
%%% is going to be a 2D plotter, so its fine
offset = max(dx, abs(((extents(1,4) + 2 * dx) .* resolution / resolution(1) - extents(:,4)) / 2));
limits(:,1) = extents(:,2) - offset;
limits(:,2) = extents(:,3) + offset;

grid = {(round(limits(1,1) / dx) * dx - 10 * dx):dx:(round(limits(1,2) / dx) * dx + 10 * dx);
        (round(limits(2,1) / dx) * dx - 10 * dx):dx:(round(limits(2,2) / dx) * dx + 10 * dx)};
    
%// get element connectivity lines on each block
connectivity = cell(1, num_blocks);
for b = 1:num_blocks
    connectivity{b} = zeros((num_local_nodes + 1), num_dims, num_elems);
    for e = 1:num_elems
        idx = mesh(e,1:(num_dims + 1):end);
        connectivity{b}(:,:,e) = [displaced_nodes(idx,1:2); displaced_nodes(idx(1),1:2)];
    end
end


%%% my linear interpolation function will be useful for interpolating the colorbar, with extrapolate
%%% as false, because I'm gonna set the color bar limits to max and min displacements of course.
%%% however, I still shall interpolate using my shape functions.
    
% also get jet here
% ramp = repmat(linspace(1, 0, resolution(2)).', 1, resolution(1)); % Create gray ramp 

figure(1)
set(gcf, 'Units', 'normalize', 'Position', [0.125, 0.25, 0.75, 0.75])
ax = axes('Position', [0.05, 0.05, 0.9, 0.9]);

%/ plot nodes
plot(displaced_nodes(:,1), displaced_nodes(:,2), 'o', 'markerfacecolor', [0, 0, 0], 'markersize', 2)
hold on

%/ loop through mesh blocks and plot each element
plot(connectivity{1}(1,:,1), connectivity{1}(2,:,1))
for b = 1:num_blocks
    for e = 1:num_elems
        plot(connectivity{b}(:,1,e), connectivity{b}(:,2,e), 'Color', 'b')
    end
end

xlim(limits(1,:))
xticks(grid{1})
ylim(limits(2,:))
yticks(grid{2})
set(gca,'Layer', 'top')

%// set gradient background
bgx = [limits(1,1), limits(1,2), limits(1,2), limits(1,1)];
bgy = [limits(2,1), limits(2,1), limits(2,2), limits(2,2)];

%0.325, 0.545, 0.78 %0.40, 0.596, 0.804 (other nice monochrome colors)
cdata(1,1,:) = [0.475, 0.647, 0.827];
cdata(1,2,:) = [0.475, 0.647, 0.827];
cdata(1,3,:) = [0.196, 0.396, 0.608];
cdata(1,4,:) = [0.196, 0.396, 0.608];
p = patch(bgx, bgy, 'k', 'Parent', ax);
set(p, 'CData', cdata, 'FaceColor','interp', 'EdgeColor', 'none');
uistack(p, 'bottom') % Put gradient underneath everything else

%%% DAMN ima have to come up with my own tic for the colorbar lmao
colormap jet(256)
c = colorbar;
ylabel(c, 'Real Displacement') % or just displacement, depending on if scale is 1 or not
caxis([min(disp_mag), max(disp_mag)])




