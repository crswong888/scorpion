%%% Attempts to solve an equation, f(x) = 0, using the Newton-Raphson method with finite difference.
%%% 
%%% By: Christopher Wong | crswong888@gmail.com

function x = newtonSolve(f, p, max_it, R_tol, varargin)
    %// parse and validate function inputs
    params = validParams(f, p, max_it, R_tol, varargin{:});
    
    %// initialize numerical procedure
    q = arrayfun(f, p); % residuals at initial secant vertices 'p' (root approximations)
    df = (q(2) - q(1)) / (p(2) - p(1)); % initial secant (finite difference)
    n = 1; % iteration count
    
    %// iterate until method converges or specified maximum number of iterations is reached
    while (n <= max_it)
        %/ compute x-intercept (root) of secant line and evaluate residual at that point
        x = p(2) - q(2) / df;
        R = f(x);
        
        %/ return root if convergence criteria is satisfied
        if (abs(R) <= R_tol)
            % report converged residual if console output is requested
            if (params.Results.Console)
                fprintf('Newton solver converged at R = %g with %d iterations.\n\n', R, n)
            end
            
            % all done :)
            return
        end
        
        %/ set lower bound of secant to old upper bound and set current approximation as new upper
        p(1) = p(2); q(1) = q(2); % swap lower bound pair
        p(2) = x; q(2) = R; % set up upper pair
        
        %/ assert that estimate for root is changing
        if (q(2) == q(1))
            error(['Newton solver has stalled. Try using a looser residual tolerance or ',...
                   'changing other numerical controls. The current residual is R = %g.'], R)
        end
        
        %/ update secant lines if using traditional Newton-Raphson iterations
        if (params.Results.Secant)
            df = (q(2) - q(1)) / (p(2) - p(1));
        end
        
        %/ update iteration count
        n = n + 1;
    end
    
    %// if solver failed - terminate execution
    error(['Newton solver failed to converge before reaching the specified maximum number of ',...
           'iterations (%d). The current residual is R = %g.'], max_it, R)
end

%%% Helper function for parsing input parameters, setting defaults, and validating data types
function params = validParams(f, p, max_it, R_tol, varargin)
    %// validate required inputs
    validateattributes(f, {'function_handle'}, {'scalar', 'real'}, 1)
    validateattributes(p, {'numeric'}, {'vector', 'numel', 2, 'real'}, 2)
    validateattributes(max_it, {'numeric'}, {'scalar', 'positive', 'integer'}, 3)
    validateattributes(R_tol, {'numeric'}, {'scalar', 'nonnegative'}, 4)
    
    %// create parser object for additional inputs
    params = inputParser;
    
    %/ whether or not to re-compute finite differences on each iteration - when 'false', this method
    %/ is sometimes referred to as a "Modified Newton-Raphson"
    valid_bool = @(x) validateattributes(x, {'logical'}, {'scalar'});
    addParameter(params, 'Secant', true, valid_bool)
    
    %/ whether or not to report final residual to console upon converging
    addParameter(params, 'Console', true, valid_bool)
    
    %/ run parser
    parse(params, varargin{:})
end