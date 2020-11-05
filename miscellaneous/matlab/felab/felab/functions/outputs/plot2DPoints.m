function [] = plot2DPoints(plt, cmap, clim, field, displaced_nodes, varargin)
    %// parse additional inputs which control plot behavior
    params = inputParser;
    addParameter(params, 'Ghost', false, @(x) islogical(x))
    valid_gp = @(x) validateattributes(x, {'matlab.graphics.chart.primitive.Line'}, {});
    addParameter(params, 'GhostPlot', [], valid_gp)
    addParameter(params, 'Contours', true, @(x) islogical(x))
    parse(params, varargin{:})
    
    %// if desired, plot undeformed mesh to be superimposed by deformed mesh
    if (params.Results.Ghost)
        validateRequiredParams(params, 'GhostPlot')
        set(params.Results.GhostPlot, 'Visible', 'on', 'MarkerSize', 4.5)
    end
    
    %// render nodes in their displaced configuration
    if (params.Results.Contours)
        %/ if points and contours, interpolate colormap index to indicate nodal field values
        set(plt, 'Visible', 'off')
        for i = 1:length(displaced_nodes(:,1))
            idx = round(1 + (field(i) - clim(1)) * (length(cmap(:,1)) - 1) / (clim(2) - clim(1)));
            plot(displaced_nodes(i,1), displaced_nodes(i,2), 'o', 'MarkerFaceColor', cmap(idx,:),...
                 'MarkerEdgeColor', 'none', 'MarkerSize', 4.5);
        end
    else
        %/ make node plot points bigger
        set(plt, 'MarkerSize', 4.5)
    end
end
