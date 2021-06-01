%%% Creates a uniformly distributed array of values along a specified domain '[s_start, s_end]' at
%%% intervals of 'ds'. If 's_start' is greater than 's_end', then values will run in descending
%%% order. The last point is always 's_end', even if the domain length is not divisible by 'ds'.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function [s, n] = generate1DGridPoints(s_start, s_end, ds)
    %// validate required inputs
    validateattributes(s_start, {'numeric'}, {'scalar', 'real'}, 1)
    validateattributes(s_end, {'numeric'}, {'scalar', 'real'}, 2)
    validateattributes(ds, {'numeric'}, {'scalar', 'real', '<=', abs(s_start - s_end)}, 3)
    
    %// fill grid points with interval values
    if (s_start < s_end)
        s = s_start:ds:s_end;
        
        %/ concatenate 's_end' in case domain not wholly divisible by 'ds'
        if (s(end) ~= s_end)
            s(end + 1) = s_end;
        end
    else
        s = flip(s_end:ds:s_start);
        
        %/ concatenate 's_start' in case domain not wholly divisible by 'ds'
        if (s(1) ~= s_start)
            s = [s_start, s];
        end
    end
    
    %// convenient output (but could easily be determined outside of this function)
    n = length(s);
end