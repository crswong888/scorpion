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

function [] = plotTimeSeries(t, series, varargin)
    %// object for additional inputs which control plot behavior
    params = inputParser;
    
    %// series must be a row vector equal in length to 't' - provide multiple by concatenating rows
    N = length(t);
    valid_series = @(x) validateattributes(x, {'numeric'}, {'ncols', N});
    addRequired(params, 'Series', valid_series)
    
    %// parse provided inputs
    parse(params, series, varargin{:})
    
    
    %%% this will be handled by a parameter
    %close all
    
%axmargs = get(axes(figure('Visible', 'off', 'OuterPosition', pos), 'Units', 'pixels'), 'TightInset');
    
    %//
    res = get(0, 'ScreenSize');
    pos = [res(1) + res(3) / 4, res(2) + res(4) / 2 - 3 * res(3) / 20, res(3) / 2, 3 * res(3) / 10];
    
    %//
    margs = [0.01, 0.02]; % minimum vertical and horizontal tight space margins
    for p = 1:1%length(series(:,1))
        %/
        figure('OuterPosition', pos);      
        plot(t, series(p,:))
        hold on
        
        %/
        set(gca, 'Fontsize', 10);
        th = title(gca, 'This Is A Plot', 'Units', 'normalized');
        %th.Position(2) = th.Position(2) + margs(2) / 2;
        xlabel('X Axis')
        ylabel('Y Axis')
        
        %/ 'TightInset' is a read-only prop - this attempts to modify it w/o knowing how it works
        axpos = get(gca, 'Position');
        axtight = get(gca, 'TightInset');
        hshift = max([axpos(1) - max(axtight(1), margs(1)), axtight(1), margs(1)]) + margs(1);
        vshift = max([axpos(2) - max(axtight(2), margs(2)), axtight(2), margs(2)]) + margs(2);
        hstretch = max(axpos(1) + axpos(3) + min(axtight(3), margs(1)), 1 - max(axtight(3), margs(1))) - margs(1) - hshift;
        
        axpos(2) + axpos(4) + min(axtight(4), margs(2))
        1 - max(axtight(4), margs(2))
        
        vstretch = max(axpos(2) + axpos(4) + min(axtight(4), margs(2)), 1 - max(axtight(4), margs(2))) - margs(2) - vshift;
        %th.Position(2) = th.Position(2) + margs(2) / 2;
        set(gca, 'Position', [hshift, vshift, hstretch, vstretch]);
        
        %th.Position(2) = th.Position(2) + margs(2) / 2;
        
        %/
        grid on
        grid minor
    end  
end