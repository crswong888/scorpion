%%% Evaluates a function, f, discretized in the form of abscissa-ordinate pairs at x = p. If p lies 
%%% between two abscissa, f(p) will be linearly interpolated.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function fx = linearInterpolation(x, f, p, varargin)
    %// parse & validate function inputs
    params = validParams(x, f, p, varargin{:});
    
    %// assert domain boundaries if not extrapolating
    if (~params.Results.Extrapolate && ((p < x(1)) || (x(end) < p)))
        error(['The specified target point is outside the provided domain of abscissa values. ',...
               'Setting the ''Extrapolate'' parameter to true will allow this and assume that ',...
               'the first or last segment continues on linearly and indefinitely.'])
    end
    
    %// locate lower bound index of subdomain holding 'x' - use lower index of first or last
    %// subdomain if extrapolating and 'p' is outside global bounds
    [~, idx] = max([x(x(1:(end - 1)) < p), x(1)]);
    
    %// compute ordinate at target point using linear interpolation between neighboring abscissa
    fx = f(idx + 1) - (x(idx + 1) - p) * (f(idx + 1) - f(idx)) / (x(idx + 1) - x(idx));
end

%%% Helper function for parsing input parameters, setting defaults, and validating data types
function params = validParams(x, f, p, varargin)
    %// validate required inputs 
    validateattributes(x, {'numeric'}, {'vector', 'increasing'}, 1)
    validateattributes(f, {'numeric'}, {'vector', 'numel', length(x), 'real'}, 2)
    validateattributes(p, {'numeric'}, {'scalar', 'real'}, 3)
    
    %// create parser object for input controlling whether or not to extrapolate beyond domain of x
    params = inputParser;
    addParameter(params, 'Extrapolate', false, @(x) islogical(x));
    
    %/ run parser
    parse(params, varargin{:})
end
