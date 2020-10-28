function [] = render2DSolution(nodes, eleblk, eletype, num_dofs, real_idx_diff, Q, varargin)   
    %// this assumes that input is a cell array of element blocks - convert to cell if not
    if (~iscell(eleblk)), eleblk = {eleblk}; end
    if (~iscell(eletype)), eletype = {eletype}; end
    
    %// valid additional inputs
    valid_element = @(x) all(ismember(x, {'B2D2', 'CPS4', 'R2D2', 'RB2D2' 'SB2D2', 'T2D2'}));
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
    
    %/ simplify some parser syntax
    eletype = params.Results.eletype;
    component = valid_component(params.Results.Component);
    style = valid_style(params.Results.Style);
    contours = params.Results.Contours;
    scale_factor = params.Results.ScaleFactor;
    Nx = params.Results.SamplesPerEdge;
    
    %/ if displacement scale factor is 0, turn off contours.
    if (scale_factor == 0)
        contours = false;
    end
    
    %// convenience variables
    num_nodes = length(nodes{:,1});
    num_blocks = length(eleblk);
    num_elems = zeros(1, num_blocks);
    for b = 1:num_blocks
        num_elems(b) = length(eleblk{b}(:,1));
    end
    
    %// this process could potentially take more than a few moments, so let user know its working
    if (sum(num_elems) * Nx > 2e3)
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
        if (all(ismember(eletype{:}, {'B2D2', 'SB2D2'})))
            comp = 3;
        else
            error(['The field component for contour plots may not be ''rot_z'' unless the mesh ',...
                   'uses standard beam elements exclusively, i.e., B2D2 and SB2D2.']);
        end
    end
    
    %// retrieve nodal values and displace original mesh
    displaced = zeros(num_nodes, 2);
    fld = zeros(num_nodes, 1);
    for i = 1:num_nodes
        %/ determine DOF positions in global displacement index
        idx = num_dofs * (i - 1) + transpose(1:num_dofs);
        real_idx = idx - real_idx_diff(idx);

        %/ apply scaled displacements to nodes and get their new positions
        displaced(i,:) = nodes{i,([1, 2] + 1)} + transpose(scale_factor * Q(real_idx(1:2)));

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
            if (strcmp(eletype{b}, 'B2D2'))
                [coords{:,b}, subfld{b}] = fieldB2D2(eleblk{b}, num_dofs, real_idx_diff, Q,...
                                                     'SamplesPerEdge', Nx,...
                                                     'ScaleFactor', scale_factor,...
                                                     'Component', component);
                
            elseif (strcmp(eletype{b}, 'CPS4'))
                if (~strcmp(component, 'rot_z'))
                    [coords{:,b}, subfld{b}] = fieldCPS4(eleblk{b}, num_dofs, real_idx_diff, Q,...
                                                         'SamplesPerEdge', Nx,...
                                                         'ScaleFactor', scale_factor,...
                                                         'Component', component);
                else
                    [coords{:,b}, subfld{b}] = fieldCPS4(eleblk{b}, num_dofs, real_idx_diff, Q,...
                                                         'SamplesPerEdge', Nx,...
                                                         'ScaleFactor', scale_factor,...
                                                         'Component', 'none');
                end
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

    %/ plot nodes to initialize a plot space
    plt = plot(displaced(:,1), displaced(:,2), 'o', 'MarkerFaceColor', 'w', 'MarkerSize', 2.5,...
                         'MarkerEdgeColor', 'none');
    hold on
    
    % append note about contour values being unscaled and plot space being scaled
    plot_scale_note = [];
    contour_scale_note = [];
    if (scale_factor ~= 1)
        plot_scale_note = [' (', num2str(scale_factor), '\bf{\times} displacement)'];
        contour_scale_note = ' (unscaled)';
    end
    
    % set axes and plot title (TODO: make these properties controllable by input parser)
    set(ax, 'FontSize', 9)
    title(['Deformed Mesh', plot_scale_note], 'FontSize', 12)
    xlabel('X Axis')
    ylabel('Y Axis')
    
    % define color mapping system for plot contours
    cmap = colormap(jet(256)); % might be helpful to know the colormap even if its not used
    if (contours)
        % create colot bar and define its limtis
        c = colorbar;
        ylabel(c, [component, contour_scale_note], 'Interpreter', 'none', 'FontSize', 9)
        clim = [min(fld), max(fld)];
        if (all(isequal(clim, [0, 0]))) 
            clim = [0, 1]; % unambigous color bar for case of zero-value field
        end
        set(ax, 'CLim', clim)
    end

    %/ loop through mesh blocks and plot each element
    if ((strcmp(style, 'surface with edges')) || (strcmp(style, 'surface')))
        %%% if 2 node element, invoke wirefram plot function, also reapply plt nodes on bottom
        
        for b = 1:num_blocks
            plot2DSurface(ax, plt, cmap, coords(:,b), subfld{b}, connectivity{b}, 'Style', style,...
                          'Contours', contours) 
        end
    elseif (strcmp(style, 'wireframe'))
        set(plt, 'Visible', 'off')
        for b = 1:num_blocks
            if (contours)
                for e = 1:num_elems(b)
                    sample_val = [subfld{1,b}(1:end,1,e);
                                  transpose(subfld{1,b}(end,2:end,e)); 
                                  flip(subfld{1,b}(1:(end - 1),end,e));
                                  flip(transpose(subfld{1,b}(1,2:(end - 1),e)))];
                    
                    p = patch(connectivity{b}(:,1,e), connectivity{b}(:,2,e), 'k', 'Parent', ax);
                    set(p, 'CData', sample_val, 'FaceColor', 'none',...
                        'CDataMapping', 'scaled', 'EdgeColor', 'interp');
                end
            else
                for e = 1:num_elems(b)
                    plot([connectivity{b}(:,1,e); connectivity{b}(1,1,e)],... 
                         [connectivity{b}(:,2,e); connectivity{b}(1,2,e)], 'Color', 'w')
                end
            end
        end
    else % points plot
        if (contours)
            % if points and contours, interpolate colormap to indicate nodal field values
            set(plt, 'Visible', 'off')
            for i = 1:num_nodes
                rgb = cmap(round(1 + (fld(i) - clim(1)) * (128 - 1) / (clim(2) - clim(1))),:);
                plot(displaced(i,1), displaced(i,2), 'o', 'MarkerFaceColor', rgb,...
                     'MarkerEdgeColor', 'none', 'MarkerSize', 4.5);
            end
        else
            % make node plot points bigger
            set(plt, 'MarkerSize', 4.5)
        end
    end
    
    %/ set up plot space with a 1:1 ratio for both dimensions
    set(ax, 'Units', 'pixels');
    resolution = [max(ax.Position(3:4)); min(ax.Position(3:4))]; % current resolution of axes window
    set(ax, 'Units', 'normalize') % convert it back so window scaling continues to work

    % determine spatial extents of displaced mesh
    extents = zeros(2, 4);
    extents(:, 1) = 1:2;
    for s = 1:2
        extents(s, 2) = min(displaced(:,s));
        extents(s, 3) = max(displaced(:,s));
    end
    extents(:,4) = extents(:,3) - extents(:,2);
    [~, smax] = max(extents(:,4));

    % determine a grid tick spacing for long dimension that conforms well to extents of displaced domain
    lowest = Inf;
    for i = 10:20 % minum of 10 increments and a maximum of 20
        for m = [5, 2, 1] % some order of magnitude of a multiple 5 is best, 2 is okay, and 1 not best
            % test a grid spacing and see how close it gets to an integer division (nice and clean)
            commdom = m * 10^(sign(log10(extents(smax,4) / i)) * floor(abs(log10(extents(smax,4) / i))) - 2);
            remainder = abs(extents(smax,4) - round(extents(smax,4) / i / commdom) * commdom * i);

            % attempt to find a number of divisions that comes closest to covering entire extent
            if (remainder < lowest)
                lowest = remainder;
                dx = round(extents(smax,4) / i / commdom) * commdom;
            end
        end
    end

    % offset extents to have a uniform empty spacing around displaced mesh domain - this preserves scale
    offset = max(dx, abs(((extents(smax,4) + 2 * dx) .* resolution / resolution(smax) - extents(:,4)) / 2));
    lims(:,1) = extents(:,2) - offset;
    lims(:,2) = extents(:,3) + offset;

    % set up grid points in extended space and 10 more points in all directions beyond
    grid = {(round(lims(1,1) / dx) * dx - 10 * dx):dx:(round(lims(1,2) / dx) * dx + 10 * dx);
            (round(lims(2,1) / dx) * dx - 10 * dx):dx:(round(lims(2,2) / dx) * dx + 10 * dx)};
        
    % set properties for axis object
    set(ax, 'XLim', lims(1,:), 'XTick', grid{1}, 'YLim', lims(2,:), 'YTick', grid{2}, 'Layer', 'top')

    %/ set gradient background
    bgx = [lims(1,1), lims(1,2), lims(1,2), lims(1,1)]; % coordinates of extended plot space vertices
    bgy = [lims(2,1), lims(2,1), lims(2,2), lims(2,2)];
    
    %%% devel - need to position this right
    wm = text(0, 0, 'This program was developed by Christopher J. Wong [crswong888@gmail.com]',...
              'Color', 'w');
    uistack(wm, 'bottom')

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
%     range(lims(1,:)) / range(lims(2,:))
%     lims(1,2) - extents(1,3)
%     lims(1,1) - extents(1,2)
%     lims(2,2) - extents(2,3)
%     lims(2,1) - extents(2,2)
end