%%%
%%%
%%% By: Christopher Wong | crswong888@gmail.com


%%% multilayout plot only uses 1 title
%%%
%%% format 'separate' or 'layout', if layout - max number or series is 6 (3x3)
%%%
%%% if layout titles, don't render titles for individual plots, otherwise, render them
%%%
%%% possibly include an 'abscissa' and 'ordinates' parameter for using separate data sizes, in which
%%% case, the t and series params must be made optional, but then required if no abscissa-ordinates,
%%% also if abscissa-ordinates, make them mutually dependent
%%%
%%% at some point, if there really is time, it would be interesting to try getting superimposed
%%% plots into a tiled layout
%%%
%%% superimposed plots have to have their own titles


function [] = plotTimeSeries(time, series, varargin)
    %// object for additional inputs which control plot behavior
    params = inputParser;
    
    %/ series must be a row vec equal in length to 'time' - provide multiple by concatenating rows
    N = length(time);
    num_series = length(series(:,1));
    valid_series = @(x) validateattributes(x, {'numeric'}, {'ncols', N});
    addRequired(params, 'Series', valid_series)
    
    %/ cell array of plot titles and axis labels for each 'series' - use 'none' to hide titles
    valid_title = @(x) ischar(x) || isstring(x);
    valid_titles = @(x) valid_title(x) || (iscell(x) && all(cellfun(valid_title, x)));
    addParameter(params, 'Title', "", @(x) valid_titles(x) && (length(string(x)) == num_series))
    addParameter(params, 'XLabel', "Time", valid_title);
    addParameter(params, 'YLabel', "", @(x) valid_titles(x) && (length(string(x)) == num_series));
    
    %/
    valid_layout = @(x) isnumeric(x) && (numel(x) == length(x)) && (1 < length(x))...
                        && (length(x) < 7) && (max(x) <= num_series);
    valid_layouts = @(x) (numel(x) == length(x)) && all(cellfun(valid_layout, x));
    addParameter(params, 'TiledLayout', [], @(x) valid_layout(x) || (iscell(x) && valid_layouts(x)))
    addParameter(params, 'LayoutTitle', "", valid_titles)
    
    %/ font to use on plot axes
    valid_font = @(x) ischar(x) || (isstring(x) && (length(x) == 1));
    addParameter(params, 'FontName', 'Helvetica', valid_font)
    
    %/ sizing parameter - controls font sizes, line thickness, window width, etc.
    addParameter(params, 'SizeFactor', 1, @(x) mustBeMember(x, [1, 2, 3, 4, 5]));
    
    %/ wether or not to close all currently open plots before generating new ones
    addParameter(params, 'ClearFigures', true, @(x) islogical(x));
    
    %// parse provided inputs
    parse(params, series, varargin{:})
    
    %/ simplify pointer syntax
    layouts = params.Results.TiledLayout;
    plot_titles(1:num_series) = string(params.Results.Title);
    x_label = string(params.Results.XLabel);
    y_labels(1:num_series) = string(params.Results.YLabel);
    ftname = params.Results.FontName;
    size_factor = params.Results.SizeFactor;
      
    %/ convert variables to cells if necessary and set number of tilesets to plot
    if (~iscell(layouts)), layouts = {layouts}; end
    if (~isempty(layouts{1})), num_layouts = length(layouts); else, num_layouts = 0; end
    
    % check that titles are provided for each layout if at all (hard to do this before parsing)
    layout_titles = params.Results.LayoutTitle;
    if (~ismember('LayoutTitle', params.UsingDefaults) && (length(layout_titles) ~= num_layouts))
        error(['The number of strings provided for ''LayoutTitle'' (',... 
               num2str(length(layout_titles)), ') must be equal to the number of plot sets ',...
               'provided for ''TiledLayout'' (', num2str(num_layouts), ').'])
    else
        layout_titles(1:num_layouts) = string(layout_titles);
    end
    
    %/ construct array of all series indices placed in a tiled plot layout
    all_layouts = [];
    for t = 1:num_layouts
        if (isrow(layouts{t}))
            all_layouts = cat(2, all_layouts, layouts{t});
        else
            all_layouts = cat(2, all_layouts, transpose(layouts{t}));
        end
    end
    
    % now append all individual plots (ones not in layouts) to 'layouts' cell array for tab indexing
    indvl = setdiff(1:num_series, all_layouts);
    if (isempty(layouts{1}))
        layouts = num2cell(indvl);
    elseif (isrow(layouts))
        layouts = cat(2, layouts, num2cell(indvl));
    else
        layouts = cat(1, layouts, num2cell(transpose(indvl)));
    end
    
    %// convenience variables
    num_tabs = length(layouts); 
    sfdom = [1, 5]; % size factor domain boundaries used for interpolations
    
    %/ generate alphanumeric array for tab indexing
    tab = string(transpose('A':'Z'));
    for p = 1:(ceil(num_tabs / 26) - 1)
        letters(1:26,1) = tab(p);
        tab = cat(1, tab, join(cat(2, letters, tab(1:26)), ''));
    end
    
    %/ get current matlab version for handling position constraint property (9.8 is 2020a)
    pos_arg = 'PositionConstraint';
    if (verLessThan('matlab', '9.8'))
        pos_arg = 'ActivePositionProperty';
    end
    
    %/ map size factor onto fontsizes [12.5, 22.5] pts for invidiual plots
    title_ftsize = linearInterpolation(sfdom, [10, 18], size_factor);
    ftsize = title_ftsize / 1.1; % default title font multiplier is 1.1, so scale down
    
    %// clear plot objects, if desired
    if (params.Results.ClearFigures)
        close all
    end
    
    %// map size factor onto figure window widths and select aspect ratios based on plot layouts 
    screen = get(groot, 'ScreenSize');
    wr = linearInterpolation(sfdom, [0.29, 0.45], size_factor);
    switch max(cellfun(@(x) length(x), layouts))
        case 1
            aspect = 43 / 80;
            max_tiles = [1, 1];
        case 2
            aspect = 25 / 40;
            max_tiles = [2, 1];
        case 3
            aspect = 16 / 20;
            max_tiles = [3, 1];
        otherwise
            wr = linearInterpolation(sfdom, [0.58, 0.9], size_factor);
            aspect = 8 / 20;
            max_tiles = [3, 2];
    end
    
    %/ compute results and initialize figure with 'OuterPosition' prop
    res = wr * screen(3) * [1, min(screen(4) / screen(3) / wr, aspect)]; % [width, height] px
    pos = [screen(1) + (screen(3) - res(1)) / 2, screen(2) + (screen(4) - res(2)) / 2, res];
    figure('OuterPosition', pos)
    
    %// 
    max_res = [0.99, 0.98]; % max normalized width and height used for layout with most tiles
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
            selections = [1.0, 1.0, 1.0, 0.5; % width scale factors
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
            
            plot(time, series(current(p),:), 'Color', [0, 0, 0],...
                 'LineWidth', linearInterpolation(sfdom, [1, 1.4], size_factor))
            hold on
            set(ax, 'FontName', ftname, 'FontSize', ftsize)
            
            %/
            tstring = plot_titles(current(p));
            if (tstring ~= "none")
                if (tstring == "")
                    tstring = "Time Series " + num2str(current(p));
                end
                % TODO: need to shift this upward
                title(ax, tstring)
            end
            
            %/
            ylabel(y_labels(current(p)))
            if (ismember(idx(p), set_label))
                %%% xlabel(x_label)
                check = xlabel(x_label);
            else
                set(ax, 'XTickLabel', {})
            end
            
            grid on
            hold off
        end
        
        %%% devel checks
        check_tab = tab(t)
%         check_lw = linearInterpolation(sfdom, [1, 1.4], size_factor)
%         check_tft = check.FontSize
        set(ax, 'Units', 'pixels')
        check_width = ax.Position(3)
        check_height = ax.Position(4)
        check_aspect = ax.Position(3) / ax.Position(4)
        set(ax, 'Units', 'normalized')
    end
    
%     %// loop through all input series and plot each one against time
%     m = [0.005, 0.02]; % minimum vertical and horizontal tight space margins
%     indvl = 1:num_series;
%     for p = indvl(~ismember(indvl, layouts{:})) 
%         %%% devel: after geting the size of the fig right for layouts, come back here and try to 
%         %%% finesse the same plot ratios (but only for the case of existing tile tabs!)
%         %%% 
%         %%% honestly, probably could just used the dimensions of largest tile then center that bish
%         %%% in accordance with its outerposition
%         
%         %/ create unique axes object in new tab, plot series, and set font style
%         ax = axes(uitab('Title', tab(count))); %#ok<LAXES>
%         plot(time, series(p,:), 'Color', [0, 0, 0],...
%              'LineWidth', linearInterpolation([2, 10, 24], [1, 1, 1.7], ftsize))
%         hold on
%         set(ax, 'FontName', ftname, 'FontSize', ftsize)
%         
%         %/ set plot title - shift it up from top plot border by a smidge
%         tset = zeros(1, 4);
%         if (~strcmp(plot_titles(p), "none"))
%             current = plot_titles(p);
%             if (current == "")
%                 current = ['Time Series ', num2str(p)];
%             end
%             th = title(current, 'Units', 'normalized', 'FontUnits', 'normalized');
%             tset = [th.Position + [0, m(2) * ftsize / 20, 0], th.FontSize];
%             set(th, 'Position', tset(1:3), 'FontUnits', 'points'); % not resetting units on purpose
%         end
%         
%         %/ set axis labels if there are ones
%         if ((x_label ~= "") && (x_label ~= "none"))
%             xlabel(x_label)
%         end
%         if ((y_labels(p) ~= "") && (y_labels(p) ~= "none"))
%             ylabel(y_labels(p))
%         end
%         
%         %/ 'TightInset' is a read-only prop - this attempts to modify it w/o knowing how it works
%         axtight = get(ax, 'TightInset');
%         shift = [max(axtight(1), m(1)) + m(1),...
%                  max(axtight(2), m(2)) + m(2),...
%                  1 - max(axtight(3), m(1)) - m(1),...
%                  1 - max(axtight(4), m(2)) - m(2) - tset(4)];
%         shift(3:4) = shift(3:4) - shift(1:2);
%         set(ax, 'Position', shift, pos_arg, 'outerposition')
%         
%         %/ toggle gridlines
%         grid on
%         grid minor
%         
%         hold off
%         count = count + 1;
%     end
end