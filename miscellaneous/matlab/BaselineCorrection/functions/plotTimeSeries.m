%%%
%%%
%%% By: Christopher Wong | crswong888@gmail.com


%%% need warning that time and all series equal length
%%% this would probably be a good time to use validate attributes to ensure row vectors
%%%
%%% need a clear figures option (default is yes clear)
%%%
%%% titles not required, default plot title is series 1, 2, ...
%%%
%%% multilayout plot only uses 1 title
%%%
%%% fontsize and fontname can definitely be their own params (run on mac to test fontname)
%%%
%%% probably need to find way to switch back and forth on 'ActivePositionProperty' and 
%%% 'PositionConstraint' depending on current matlab version


function [] = plotTimeSeries(t, series, varargin)
    %// object for additional inputs which control plot behavior
    params = inputParser;
    
    %/ series must be a row vector equal in length to 't' - provide multiple by concatenating rows
    N = length(t);
    valid_series = @(x) validateattributes(x, {'numeric'}, {'ncols', N});
    addRequired(params, 'Series', valid_series)
    
    %/ font to use on plot axes and title test
    addParameter(params, 'FontName', 'Helvetica')
    
    %// parse provided inputs
    parse(params, series, varargin{:})
    
    
    %%% this will be handled by a parameter
    %close all
    
    
    %//
    res = get(0, 'ScreenSize');
    aspect = 9 / 20 * res(3) * [1, 2 / 5];
    pos = [res(1) + (res(3) - aspect(1)) / 2, res(2) + (res(4) - aspect(2)) / 2, aspect];
    
    %//
    m = [0.01, 0.02]; % minimum vertical and horizontal tight space margins
    for p = 1:1%length(series(:,1))
        %/
        figure('OuterPosition', pos);      
        plot(t, series(p,:))
        hold on
        
        %/
        set(gca, 'FontName', 'Helvetica', 'FontSize', 10);
        th = title('This Is A Plot', 'Units', 'normalized', 'FontUnits', 'normalized');
        tset = [th.Position + [0, m(2) / 2, 0], th.FontSize]; 
        set(th, 'Position', tset(1:3), 'Units', 'data', 'FontUnits', 'points');
        xlabel('X Axis')
        ylabel('Y Axis')
        
        %/ 'TightInset' is a read-only prop - this attempts to modify it w/o knowing how it works
        axp = get(gca, 'Position');
        axt = get(gca, 'TightInset');        
        shift = [max([axp(1) - max(axt(1), m(1)), axt(1), m(1)]) + m(1),...
                 max([axp(2) - max(axt(2), m(2)), axt(2), m(2)]) + m(2),...
                 max(axp(1) + axp(3) + min(axt(3), m(1)), 1 - max(axt(3), m(1))) - m(1),...
                 max(axp(2) + axp(4) + min(axt(4), m(2)), 1 - max(axt(4), m(2))) - m(2) - tset(4)];
        shift(3:4) = shift(3:4) - shift(1:2);
        set(gca, 'Position', shift, 'ActivePositionProperty', 'outerposition');
        
        %/
        grid on
        grid minor
    end  
end