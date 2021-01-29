%%%
%%%
%%% By: Christopher Wong | crswong888@gmail.com


function [] = plotTimeSeries(time, series, varargin)
    %// object for additional inputs which control plot behavior
    params = inputParser;
    
    %/ series must be a row vec equal in length to 'time' - provide multiple by concatenating rows
    N = length(time);
    num_series = length(series(:,1));
    valid_series = @(x) validateattributes(x, {'numeric'}, {'ncols', N});
    addRequired(params, 'Series', valid_series)
    
    %/ cell array of plot titles and axis labels for each 'series' - use 'none' to hide titles
    valid_string = @(x) ischar(x) || isstring(x);
    valid_strings = @(x) valid_string(x) || (iscell(x) && all(cellfun(valid_string, x)));
    addParameter(params, 'Title', "", @(x) valid_strings(x) && (length(string(x)) == num_series))
    addParameter(params, 'XLabel', "Time", valid_string);
    addParameter(params, 'YLabel', "", @(x) valid_strings(x) && (length(string(x)) == num_series));  
    
    %/
    valid_superimp = @(x) isnumeric(x) && (numel(x) == length(x)) && (1 < length(x))...
                     && (length(x) < 5) && (max(x) <= num_series);
    valid_superimps = @(x) (numel(x) == length(x)) && all(cellfun(valid_superimp, x));
    addParameter(params, 'Superimpose', [], @(x) valid_superimp(x)...
                                            || (iscell(x) && valid_superimps(x)))
    addParameter(params, 'SuperimposeTitle', "", valid_strings)
    addParameter(params, 'SuperimposeYLabel', "", valid_strings)
    addParameter(params, 'Legend', [], valid_strings)
    
    % control legend location - may be set once for all superimp plots, or paired for each one
    addParameter(params, 'LegendLocation', 'best', valid_strings)
    
    %/
    valid_layout = @(x) isnumeric(x) && (numel(x) == length(x)) && (1 < length(x))...
                        && (length(x) < 7);
    valid_layouts = @(x) (numel(x) == length(x)) && all(cellfun(valid_layout, x));
    addParameter(params, 'TiledLayout', [], @(x) valid_layout(x) || (iscell(x) && valid_layouts(x)))
    addParameter(params, 'LayoutTitle', "", valid_strings)
    
    %/ font to use on plot axes
    valid_font = @(x) ischar(x) || (isstring(x) && (length(x) == 1));
    addParameter(params, 'FontName', 'Helvetica', valid_font)
    
    %/ sizing parameter - controls font sizes, line thickness, window width, etc.
    addParameter(params, 'SizeFactor', 1, @(x) mustBeMember(x, [1, 2, 3, 4, 5]));
    
    %/ wether or not to close all currently open plots before generating new ones
    addParameter(params, 'ClearFigures', true, @(x) islogical(x));
    
    %// parse provided inputs
    parse(params, series, varargin{:})
    
    %// simplify pointer syntax
    plot_titles(1:num_series) = string(params.Results.Title);
    x_label = string(params.Results.XLabel);
    y_labels(1:num_series) = string(params.Results.YLabel);
    ftname = params.Results.FontName;
    size_factor = params.Results.SizeFactor;
      
    %/ convert variables to cells if necessary
    layouts = params.Results.TiledLayout;
    if (~iscell(layouts)), layouts = {layouts}; end
    if (~isempty(layouts{1})), num_layouts = length(layouts); else, num_layouts = 0; end
    
    superimps = params.Results.Superimpose;
    if (~iscell(superimps)), superimps = {superimps}; end
    if (~isempty(superimps{1})), num_superimps = length(superimps); else, num_superimps = 0; end
    
    %/ assert titles are provided for each superimposed series if at all (can't do before parsing)
    superimp_titles = string(params.Results.SuperimposeTitle);
    if (~ismember('SuperimposeTitle', params.UsingDefaults)...
        && (length(superimp_titles) ~= num_superimps))
        error(['The number of strings provided for ''SuperimposeTitle'' (',... 
               num2str(length(superimp_titles)), ') must be equal to the number of plot sets ',...
               'provided for ''Superimpose'' (', num2str(num_superimps), ').'])
    else
        superimp_titles(1:num_superimps) = superimp_titles;
    end 
    
    %/ assert y-labels are provided for each superimposed series if at all 
    superimp_labels = string(params.Results.SuperimposeYLabel);
    if (~ismember('SuperimposeYLabel', params.UsingDefaults)...
        && (length(superimp_labels) ~= num_superimps))
        error(['The number of strings provided for ''SuperimposeYLabel'' (',... 
               num2str(length(superimp_labels)), ') must be equal to the number of plot sets ',...
               'provided for ''Superimpose'' (', num2str(num_superimps), ').'])
    else
        superimp_labels(1:num_superimps) = superimp_labels;
    end
    
    %/ append superimp titles and labels to standard ones for consistent indexing
    plot_titles = [plot_titles, superimp_titles];
    y_labels = [y_labels, superimp_labels];
    
    %/ assert legend properties
    superimp_legends = params.Results.Legend;
    if (~ismember('Legend', params.UsingDefaults)) 
        % legend provided for each superimposed series if at all
        if (length(superimp_legends) ~= num_superimps)
            error(['The number of strings provided for ''Legend'' (',... 
                   num2str(length(superimp_legends)), ') must be equal to the number of plot ',...
                   'sets provided for ''Superimpose'' (', num2str(num_superimps), ').'])
        end
        
        % each legend has a number of entries equal to number of superimposed series
        if (any(cellfun(@(x, y) length(x) ~= length(y), superimps, superimp_legends)))
            error(['The number of strings provided for each cell in ''Legend'' must be equal ',...
                   'to the number of series IDs provided for each cell in ''Superimpose''.'])
        end
    end
    
    % legend locations provided either once for all superimps or for each one
    legend_locations = string(params.Results.LegendLocation);
    if (~ismember('LegendLocation', params.UsingDefaults)...
        && all(length(legend_locations) ~= [1, num_superimps]))
        error(['The number of strings provided for ''LegendLocation'' (',...
               num2str(length(legend_locations)), ') must be equal to one (applied uniformly ',...
               'to all) or the number of plot sets provided for ''Superimpose'' (',...
               num2str(num_superimps), ').'])
    else
        legend_locations(1:num_superimps) = legend_locations;
    end
    
    %/ assert titles are provided for each layout if at all (hard to do this before parsing)
    layout_titles = string(params.Results.LayoutTitle);
    if (~ismember('LayoutTitle', params.UsingDefaults) && (length(layout_titles) ~= num_layouts))
        error(['The number of strings provided for ''LayoutTitle'' (',... 
               num2str(length(layout_titles)), ') must be equal to the number of plot sets ',...
               'provided for ''TiledLayout'' (', num2str(num_layouts), ').'])
    else
        layout_titles(1:num_layouts) = layout_titles;
    end
    
    %/ assert max series ID provided to any layout set no greater than no. of unique plots
    if (any(cellfun(@(x) max(x) > num_series + num_superimps, layouts)))
        error(['The series IDs provided for cells in ''TiledLayout'' may not be greater than ',...
               'the number of unique plots (', num2str(num_series + num_superimps), ').'])
    end
    
    %/ construct array of all plot indices placed in a tiled plot layout
    all_layouts = [];
    for t = 1:num_layouts
        if (isrow(layouts{t}))
            all_layouts = cat(2, all_layouts, layouts{t});
        else
            all_layouts = cat(2, all_layouts, transpose(layouts{t}));
        end
    end
    
    % now append all individual plots (ones not in layouts) to 'layouts' cell array for tab indexing
    indvl = setdiff([1:num_series, (1:num_superimps) + num_series], all_layouts);
    if (isempty(layouts{1}))
        layouts = num2cell(indvl);
    elseif (isrow(layouts))
        layouts = cat(2, layouts, num2cell(indvl));
    else
        layouts = cat(1, layouts, num2cell(transpose(indvl)));
    end
    
    %// clear plot objects, if desired
    if (params.Results.ClearFigures)
        close all
    end
    
    %// map size factor onto fontsizes [12.5, 22.5] pts for invidiual plots
    sfdom = [1, 5]; % size factor domain boundaries used for interpolations
    title_ftsize = linearInterpolation(sfdom, [8, 16], size_factor);
    ftsize = title_ftsize / 1.1; % default title font multiplier is 1.1, so scale down
    
    %// generate alphanumeric array for tab indexing
    num_tabs = length(layouts); 
    tab = string(transpose('A':'Z'));
    for p = 1:(ceil(num_tabs / 26) - 1)
        letters(1:26,1) = tab(p);
        tab = cat(1, tab, join(cat(2, letters, tab(1:26)), ''));
    end
    
    %// get current matlab version for handling position constraint property (9.8 is 2020a)
    pos_arg = 'PositionConstraint';
    if (verLessThan('matlab', '9.8'))
        pos_arg = 'ActivePositionProperty';
    end
    
    %// map size factor onto figure window widths and select aspect ratios based on plot layouts 
    screen = get(groot, 'ScreenSize');
    wr = linearInterpolation(sfdom, [0.29, 0.45], size_factor);
    switch max(cellfun(@(x) length(x), layouts))
        case 1
            aspect = 43 / 80;
            max_tiles = [1, 1];
        case 2
            aspect = 5 / 8;
            max_tiles = [2, 1];
        case 3
            aspect = 4 / 5;
            max_tiles = [3, 1];
        otherwise
            wr = linearInterpolation(sfdom, [0.58, 0.9], size_factor);
            aspect = 2 / 5;
            max_tiles = [3, 2];
    end
    
    %/ compute results and initialize figure with 'OuterPosition' prop
    res = wr * screen(3) * [1, min(screen(4) / screen(3) / wr, aspect)]; % [width, height] px
    pos = [screen(1) + (screen(3) - res(1)) / 2, screen(2) + (screen(4) - res(2)) / 2, res];
    figure('OuterPosition', pos) 
    
    %// 
    max_res = [0.99, 0.98]; % max normalized width and height used for layout with most tiles
    color = [0.5, 0.5, 0.5; 0, 0, 0; 0.15, 0.15, 0.15; 0, 0, 0]; % color scheme for superimp plots
    linewidth = [2.8, 3.2; 0.8, 1.2; 2, 2.4; 1, 1.4]; % line width scheme for superimp plots
    linetype = [":", "-", "-.", "--"]; % linetype scheme for superimp plots
    for t = 1:num_tabs
        %/ 
        current = layouts{t};
        num_tiles = length(current);
        rows = min(num_tiles, 3);
        cols = ceil(num_tiles / rows);
        if (num_tiles < 4)
            idx = 1:num_tiles;
            set_label = num_tiles;
        else
            idx = [1, 3, 5, (14 - 2 * num_tiles):2:6]; % fills left column then right in reverse
            set_label = [5, 6];
        end
        
        %/ create new layout tab
        layout = tiledlayout(uitab('Title', tab(t)), rows, cols, 'Padding', 'none',...
                             'TileSpacing', 'compact');
                         
        %/
        if (num_tiles > 1)
            W = cols / max_tiles(2) * max_res(1);
            H = rows / max_tiles(1) * max_res(2);
            
            %
            tstring = layout_titles(t);
            if (tstring ~= "none")
                if (tstring == "")
                    tstring = "Series Layout " + tab(t);
                end
                % TODO: need to shift this upward
                title(layout, tstring, 'FontSize', 1.1 * title_ftsize)
            end
        else
            selections = [0.98, 0.98, 0.98, 0.5; % width scale factors
                          1.0, 0.78, 0.55, 0.55]; % height scale factors
            select = [1, 2, 3, 6] == max_tiles(1) * max_tiles(2); % selection by layout dimensions
            W = selections(1, select) * max_res(1);
            H = selections(2, select) * max_res(2);
        end
        
        % set outer resolution for tiled layout and constrain when resizing
        set(layout, 'OuterPosition', [(1 - W) / 2, (1 - H) / 2, W, H], pos_arg, 'OuterPosition')
        
        %/
        for p = 1:num_tiles
            ax = nexttile(layout, idx(p));
            
            %%% TODO: use cell arrays for each series to make handling simps easier - this will also
            %%% pave the way for implementing support for series with different data sizes
            if (current(p) <= num_series)
                % initialize plot and hold
                plot(time, series(current(p),:), 'Color', [0, 0, 0],...
                     'LineWidth', linearInterpolation(sfdom, [1, 1.4], size_factor))
                hold on
                
                % get min and max values
                [minval, maxval] = bounds(series(current(p),:));
            else
                impset = superimps{current(p) - num_series};
                lgdset = superimp_legends{current(p) - num_series};
                
                % initialize first plot and hold
                imp = series(impset(1),:);
                plot(time, imp, linetype(1), 'Color', color(1,:), 'DisplayName', lgdset(1),...
                     'LineWidth', linearInterpolation(sfdom, linewidth(1,:), size_factor))
                hold on
                
                % initialize min and max values from first series
                [minval, maxval] = bounds(imp);
                
                % now loop through all other series and superimpose each
                for i = 2:length(impset)
                    imp = series(impset(i),:);
                    plot(time, imp, linetype(i), 'Color', color(i,:), 'DisplayName', lgdset(i),...
                         'LineWidth', linearInterpolation(sfdom, linewidth(i,:), size_factor))
                     
                    % update min and max values if found
                end
            end
            
            
            %
            set(ax, 'FontName', ftname, 'FontSize', ftsize, 'YLim', [minval, maxval])
            tstring = plot_titles(current(p));
            if (tstring ~= "none")
                if (tstring == "")
                    tstring = "Time Series " + num2str(current(p));
                end
                % TODO: need to shift this upward
                title(ax, tstring)
            end
            
            %
            ylabel(y_labels(current(p)))
            if (ismember(idx(p), set_label))
                %%% xlabel(x_label)
                check = xlabel(x_label);
            else
                set(ax, 'XTickLabel', {})
            end
            
            % enable grid and disable graphics hold
            grid on
            grid minor
            set(ax, 'GridColor', [0, 0, 0], 'MinorGridLineStyle', '-',...
                'MinorGridColor', [0.8, 0.8, 0.8])
            hold off
            
            % add legend to superimposed plots (this is done last to ensure optimal placement)
            if (current(p) > num_series && ~isempty(superimp_legends))
                legend(ax, 'Location', legend_locations(current(p) - num_series),...
                       'Orientation', 'horizontal', 'AutoUpdate', 'off')
            end
        end
        
%         %%% devel checks
%         check_tab = tab(t)
%         check_lw = linearInterpolation(sfdom, [1, 1.4], size_factor)
%         check_tft = check.FontSize
%         set(ax, 'Units', 'pixels')
%         check_width = ax.Position(3)
%         check_height = ax.Position(4)
%         check_aspect = ax.Position(3) / ax.Position(4)
%         set(ax, 'Units', 'normalized')
    end
end