%%% Creates an array of uniformly spaced values along a specified domain.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function [s, n] = generate1DGridPoints(start_position, end_position, ds)
    %// determine length of domain
    length = end_position - start_position;
    
    %// determine no. of grid points
    n = ceil(round(abs(length) / ds / ds) * ds) + 1; % round to nearest ds avoids numerical errors
    
    %// initialize grid array
    s = zeros(1, n);
    s(1) = start_position;
    
    %// fill grid points with interval values
    if (length >= 0) 
        for i = 2:n 
            s(i) = s(i-1) + ds; 
        end
    else
        for i = 2:n
            s(i) = s(i-1) - ds; 
        end
    end
    
    %// in case end_position is not divisible by specified ds, fill s(n) with that value
    if (s(n) ~= end_position)
        s(n) = end_position; % shift last grid point back to final value
    end
end