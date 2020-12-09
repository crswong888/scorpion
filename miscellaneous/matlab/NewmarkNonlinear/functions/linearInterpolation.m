%%% Evaluates a function, f, discretized in the form of abscissa-ordinate pairs at x = p. If p lies 
%%% between two abscissa, f(p) will be linearly interpolated.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function fx = linearInterpolation(x, f, p, varargin)
    %// parse additional argument controlling wether or not to extrapolate beyond domain of x.
    params = inputParser;
    addParameter(params, 'Extrapolate', false, @(x) islogical(x));
    parse(params, varargin{:});

    %// assert equal size
    N = length(f);
    if (N ~= length(x))
        error('The arrays of abscissa and ordinate pairs must be of equal length.')
    end

    %// assert chronological sequence of domain values and locate subdomain holding x
    idx = 0;
    for i = 1:N-1
        if (x(i+1) <= x(i))
            error(['Input must be a real, single-valued function and the absiscca values must ',...
                   'increase along the ascending array direction.'])
        end
        if (p >= x(i))
            idx = i;
        end
    end
    
    %// assert domain boundaries if not extrapolating, otherwise, set correct idx value
    if ((p < x(1)) || (x(N) < p))
        if (~params.Results.Extrapolate)
            error(['The specified target point is outside the provided domain of abscissa ',...
                   'values. Setting the ''Extrapolate'' parameter to true will assume the ',...
                   'first and last segments continue in their respective directions indefinitely.'])
        elseif (p < x(1))
            idx = 1;
        else
            idx = N - 1;
        end
    end
    
    %// compute ordinate value at target point using linear interpolation
    fx = f(idx+1) - (x(idx+1) - p) * (f(idx+1) - f(idx)) / (x(idx+1) - x(idx));
end