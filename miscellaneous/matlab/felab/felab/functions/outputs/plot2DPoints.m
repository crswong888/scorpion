function [] = plot2DPoints(plt, cmap, clim, field, displaced_nodes, varargin)
    %// parse additional inputs which control plot behavior
    params = inputParser;
    addParameter(params, 'Contours', true, @(x) islogical(x))
    parse(params, varargin{:})
    
    %// get number of color indices to interpolate
    N = length(cmap(:,1));
    
    if (params.Results.Contours)
        % if points and contours, interpolate colormap to indicate nodal field values
        set(plt, 'Visible', 'off')
        for i = 1:length(displaced_nodes(:,1))
            rgb = cmap(round(1 + (field(i) - clim(1)) * (N - 1) / (clim(2) - clim(1))),:);
            plot(displaced_nodes(i,1), displaced_nodes(i,2), 'o', 'MarkerFaceColor', rgb,...
                 'MarkerEdgeColor', 'none', 'MarkerSize', 4.5);
        end
    else
        % make node plot points bigger
        set(plt, 'MarkerSize', 4.5)
    end
end
