function [] = render2DSolution(nodes, eleblk, eletype, num_dofs, real_idx_diff, Q, varargin)   
    %// this assumes that input is a cell array of element blocks - convert to cell if not
    if (~iscell(eleblk)), eleblk = {eleblk}; end
    if (~iscell(eletype)), eletype = {eletype}; end
    
    %// valid additional inputs
    valid_element = @(x) all(ismember(x, {'B2D2', 'CPS4', 'R2D2', 'RB2D2', 'SB2D2', 'T2D2'}));
    valid_component = @(x) validatestring(x, {'disp_x', 'disp_y', 'rot_z', 'disp_mag'});
    valid_style = @(x) validatestring(x, {'points', 'surface', 'surface with edges', 'wireframe'});
    
    %// parse additional inputs which control plot behavior
    params = inputParser;
    addRequired(params, 'eletype', valid_element)
    addParameter(params, 'Component', 'disp_mag', @(x) any(valid_component(x)))
    addParameter(params, 'Style', 'surface with edges', @(x) any(valid_style(x)))
    addParameter(params, 'Contours', true, @(x) islogical(x))
    addParameter(params, 'ScaleFactor', 1, @(x) isnumeric(x))
    addParameter(params, 'SamplesPerEdge', 10, @(x) ((isnumeric(x)) && (x > 1)))
    addParameter(params, 'Omega', 0, @(x) ((isnumeric(x)) && (x >= 0))) % for SB2D2 elements only
    parse(params, eletype, varargin{:})
    
    %// simplify some parser syntax
    eletype = params.Results.eletype;
    component = valid_component(params.Results.Component);
    style = valid_style(params.Results.Style);
    contours = params.Results.Contours;
    scale_factor = params.Results.ScaleFactor;
    Nx = params.Results.SamplesPerEdge;
    
    %// convenience variables
    num_nodes = length(nodes{:,1});
    num_blocks = length(eleblk);
    num_elems = zeros(1, num_blocks);
    num_local_nodes = zeros(1, num_blocks);
    for b = 1:num_blocks
        num_elems(b) = length(eleblk{b}(:,1));
        num_local_nodes(b) = length(eleblk{b}(1,2:3:end));
    end
    
    %// this process could potentially take more than a few moments, so let user know its working
    if (sum(num_elems) * Nx > 5e3)
        warning(['Plot generation may take awhile for large numbers of interpolation points ',... 
                 'to evaluate and plot. Consider inputting a smaller ''SamplesPerEdge'' value. ',...
                 'Note that linear elements need few samples per edge, say, no more than five.'])
        fprintf('\n')
    end
    fprintf('Generating plot... ')
    
    %// set position of DOF to retrieve from global index for contours on point plots
    comp = [];
    if (strcmp(component, 'disp_mag'))
        comp = [1, 2];
    elseif (strcmp(component, 'disp_x'))
        comp = 1;
    elseif (strcmp(component, 'disp_y'))
        comp = 2;
    elseif (strcmp(component, 'rot_z'))
        if (all(ismember(eletype{:}, {'B2D2', 'SB2D2', 'RB2D2'})))
            comp = 3;
        else
            error(['The field component for contour plots may not be ''rot_z'' unless the mesh ',...
                   'uses beam elements exclusively, e.g., B2D2 or SB2D2.']);
        end
    end
    
    %// retrieve nodal values and displace original mesh
    displaced_nodes = zeros(num_nodes, 2);
    fld = zeros(num_nodes, 1);
    for i = 1:num_nodes
        %/ determine DOF positions in global displacement index
        idx = num_dofs * (i - 1) + transpose(1:num_dofs);
        real_idx = idx - real_idx_diff(idx);

        %/ apply scaled displacements to nodes and get their new positions
        displaced_nodes(i,:) = nodes{i,([1, 2] + 1)} + transpose(scale_factor * Q(real_idx(1:2)));

        %/ get desired field value at node
        if (length(comp) > 1) % faster than strcmp() so thats why handle this check outside loop
            fld(i) = norm(Q(real_idx(comp)));
        else
            fld(i) = Q(real_idx(comp));
        end
    end

    %// interpolate displacement field through elements and get their nodal connectivity
    if (~strcmp(style, 'points'))
        coords = cell(2, num_blocks);
        subfld = cell(1, num_blocks);
        connectivity = cell(1, num_blocks);
        for b = 1:num_blocks
            %/ use element shape functions to interpolate nodal displacements through specified grid
            if (any(strcmp(eletype{b}, {'B2D2', 'RB2D2'})))
                [coords{:,b}, subfld{b}] = fieldB2D2(eleblk{b}, num_dofs, real_idx_diff, Q,...
                                                     'SamplesPerEdge', Nx,...
                                                     'ScaleFactor', scale_factor,...
                                                     'Component', component);
            elseif (strcmp(eletype{b}, 'CPS4'))
                [coords{:,b}, subfld{b}] = fieldCPS4(eleblk{b}, num_dofs, real_idx_diff, Q,...
                                                     'SamplesPerEdge', Nx,...
                                                     'ScaleFactor', scale_factor,...
                                                     'Component', component);
            elseif (strcmp(eletype{b}, 'SB2D2'))
                validateRequiredParams(params, 'Omega')
            elseif (strcmp(eletype{b}, 'T2D2'))
                
            end

            %/ get element connectivity lines on each block using interpolated displaced coordinates
            for e = 1:num_elems(b)
                connectivity{b}(:,:,e) = [coords{1,b}(1:end,1,e),...
                                          coords{2,b}(1:end,1,e);
                                          transpose(coords{1,b}(end,2:end,e)),... 
                                          transpose(coords{2,b}(end,2:end,e));
                                          flip(coords{1,b}(1:(end - 1),end,e)),...
                                          flip(coords{2,b}(1:(end - 1),end,e));
                                          flip(transpose(coords{1,b}(1,2:(end - 1),e))),...
                                          flip(transpose(coords{2,b}(1,2:(end - 1),e)))];
            end
        end
    end

    %// Generate a figure window with a nominal plot axes
    figure('Units', 'normalize', 'Position', [0.125, 0.25, 0.75, 0.75])
    ax = axes('Position', [0.07, 0.07, 0.88, 0.88], 'Layer', 'top');

    %/ plot nodes to initialize a plot space (these might get hidden later depending on plot style)
    plt = plot(displaced_nodes(:,1), displaced_nodes(:,2), 'o', 'MarkerFaceColor', 'w',...
               'MarkerSize', 2.5, 'MarkerEdgeColor', 'none');
    hold on
    
    %/ select plot and colorbar titles based on how field values are scaled
    plot_title = 'Deformed Mesh';
    contour_scale_note = [];
    if (scale_factor == 0) % undeformed mesh with zero-valued field
        plot_title = 'Original Mesh';
        contours = false;
    elseif (scale_factor ~= 1) % deformed mesh using scaled displacements with actual field values
        plot_title = [plot_title, ' (', num2str(scale_factor), '\bf{\times} displacement)'];
        contour_scale_note = ' (unscaled)';
    end
    
    %/ set axes and plot title (TODO: make these props controllable by user input parser scheme)
    set(ax, 'FontSize', 9)
    title(plot_title, 'FontSize', 12)
    xlabel('X Axis')
    ylabel('Y Axis')
    
    %/ define color mapping system for plot contours
    cmap = colormap(jet(256));
    clim = [min(fld), max(fld)];
    if (all(isequal(clim, [0, 0]))) 
        clim = [0, 1]; % unambigous color bar for case of zero-value field
    end
    
    %/ add colorbar if plotting field contours
    if (contours)
        % create colot bar and define its limtis
        c = colorbar;
        ylabel(c, [component, contour_scale_note], 'Interpreter', 'none', 'FontSize', 9)
        set(ax, 'CLim', clim)
    end

    %/ loop through mesh blocks and plot each element
    if (any(strcmp(style, {'surface', 'surface with edges'})))        
        for b = 1:num_blocks
            if (num_local_nodes(b) > 2)
                plot2DSurface(ax, plt, cmap, coords(:,b), subfld{b}, connectivity{b},...
                              'Style', style, 'Contours', contours)
            else % 2-noded or less elements cannot use a surface plot - use wireframe
                plot2DWireframe(ax, plt, subfld{b}, connectivity{b}, 'Contours', contours)
            end
        end
    elseif (strcmp(style, 'wireframe'))
        for b = 1:num_blocks
            plot2DWireframe(ax, plt, subfld{b}, connectivity{b}, 'Contours', contours)
        end
    else % points plot
        plot2DPoints(plt, cmap, clim, fld, displaced_nodes, 'Contours', contours)
    end
    
    %/ set up plot space with a 1:1 ratio for both dimensions
    set(ax, 'Units', 'pixels');
    resolution = [max(ax.Position(3:4)); min(ax.Position(3:4))]; % current resolution of axes window
    set(ax, 'Units', 'normalize') % convert it back so window scaling continues to work

    % determine spatial extents of displaced mesh
    extents = zeros(2, 4);
    extents(:, 1) = 1:2;
    for s = 1:2
        extents(s, 2) = min(displaced_nodes(:,s));
        extents(s, 3) = max(displaced_nodes(:,s));
    end
    extents(:,4) = extents(:,3) - extents(:,2);
    [~, smax] = max(extents(:,4)); % dimension with longest extents

    % determine a grid spacing for long dimension that conforms well to extents of displaced domain
    lowest = Inf; % initialize check for smallest non-divisible length of mesh extents
    for i = 10:20 % minum of 10 increments and a maximum of 20
        for m = [5, 2, 1] % some order of magnitude of 5 is best, 2 is okay, and 1 not best
            % test a grid spacing and see how close it gets to an integer division (nice and clean)
            commdom = m * 10^(sign(log10(extents(smax,4) / i))...
                      * floor(abs(log10(extents(smax,4) / i))) - 2);
            remainder = abs(extents(smax,4) - round(extents(smax,4) / i / commdom) * commdom * i);

            % attempt to find a number of divisions that comes closest to covering entire extent
            if (remainder < lowest)
                lowest = remainder; % update optimum value
                dx = round(extents(smax,4) / i / commdom) * commdom; % set grid spacing
            end
        end
    end

    % offset extents to have uniform empty spacing around displaced mesh domain - preserves scale
    offset = abs(((extents(smax,4) + 2 * dx) .* resolution / resolution(smax) - extents(:,4)) / 2);
    offset = max(dx, offset);
    lim(:,1) = extents(:,2) - offset;
    lim(:,2) = extents(:,3) + offset;

    % set up grid points in extended space and 10 more points in all directions beyond
    grid = {(round(lim(1,1) / dx) * dx - 10 * dx):dx:(round(lim(1,2) / dx) * dx + 10 * dx);
            (round(lim(2,1) / dx) * dx - 10 * dx):dx:(round(lim(2,2) / dx) * dx + 10 * dx)};
        
    % set properties for axis object
    set(ax, 'XLim', lim(1,:), 'XTick', grid{1}, 'YLim', lim(2,:), 'YTick', grid{2}, 'Layer', 'top')

    %/ add developer credit watermark to plot space
    wm_pos = [lim(1,2) - 0.025 * max(range(lim, 2)), lim(2,1) + 0.025 * max(range(lim, 2))];
    wm = text(ax, 'Position', wm_pos, 'HorizontalAlignment', 'right', 'Color', 'w',...
              'String', 'Developed by Christopher J. Wong [crswong888@gmail.com]');
    uistack(wm, 'bottom')
    
    %/ set gradient background
    bgx = [lim(1,1), lim(1,2), lim(1,2), lim(1,1)]; % coordinates of extended plot space vertices
    bgy = [lim(2,1), lim(2,1), lim(2,2), lim(2,2)];

    % I call this color scheme "Shallow Ocean" lol
    cdata(1,1,:) = [0.173, 0.349, 0.529]; % bottom RGB
    cdata(1,2,:) = [0.173, 0.349, 0.529];
    cdata(1,3,:) = [0.475, 0.647, 0.827]; % top RGB
    cdata(1,4,:) = [0.475, 0.647, 0.827];

    % create a patch object to render gradient
    p = patch(bgx, bgy, 'k', 'Parent', ax);
    set(p, 'CData', cdata, 'FaceColor','interp', 'EdgeColor', 'none');
    uistack(p, 'bottom') % Put gradient underneath everything else
    
    %// all done :)
    fprintf('Done.\n\n')
    
    %%% devel checks
%     resolution(1) / resolution(2)
%     range(lim(1,:)) / range(lim(2,:))
%     lim(1,2) - extents(1,3)
%     lim(1,1) - extents(1,2)
%     lim(2,2) - extents(2,3)
%     lim(2,1) - extents(2,2)
end