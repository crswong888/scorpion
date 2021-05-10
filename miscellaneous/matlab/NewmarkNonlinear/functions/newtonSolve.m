%%% Attempts to solve an equation, f(x) = 0, using the Newton-Raphson method with finite difference.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function root = newtonSolve(f, interval, max_it, R_tol, varargin)
    %// parse and validate function inputs
    params = validParams(f, interval, max_it, R_tol, varargin{:});
    
    %// compute initial approximations for residual
    p = interval; % secant vertices (root approximations)
    q = zeros(1,2); % residual at vertices
    for i = 1:2
        q(i) = f(interval(i));
    end
    
    %// iterate until method converges or specified max number of iterations is reached
    n = 1; % initialize iteration count
    while (n <= max_it)
        %/ compute x-intercept of finite difference secant line and evaluate residual
        root = p(2) - q(2) * (p(2) - p(1)) / (q(2) - q(1));
        R = f(root);
        
        %/ return root if convergence criteria is satisfied
        if (abs(R) <= R_tol)
            % report converge residual if requested
            if (params.Results.Console)
                fprintf('Newton solver converged at R = %g with %d iterations.\n\n', R, n)
            end
            
            % all done :)
            return
        end
        
        %/ set current approximation as new upper bound of secant
        p(1) = p(2); q(1) = q(2); p(2) = root; q(2) = R;
        
        %/ assert that estimate for root is changing
        if (q(2) == q(1))
            error(['Newton solver has stalled. Try using a looser residual tolerance or ',...
                   'changing other numerical controls. The current residual is R = %g.'], R)
        end
        
        %/ update iteration count
        n = n + 1;
    end
    
    %// if solver failed - terminate execution
    error(['Newton solver failed to converge before reaching the specified maximum number of ',...
           'iterations. The current residual is R = %g.'], R)
end

%%% Helper function for parsing input parameters, setting defaults, and validating data types
function params = validParams(f, interval, max_it, R_tol, varargin)
    %// validate required inputs
    validateattributes(f, {'function_handle'}, {'scalar', 'real'}, 1)
    validateattributes(interval, {'numeric'}, {'vector', 'numel', 2, 'real'}, 2)
    validateattributes(max_it, {'numeric'}, {'scalar', 'positive', 'integer'}, 3)
    validateattributes(R_tol, {'numeric'}, {'scalar', 'nonnegative'}, 4)
    
    %// create parser object for additional input controlling whether or not to report final 
    %// residual to console upon converging
    params = inputParser;
    addParameter(params, 'Console', true, @(x) validateattributes(x, {'logical'}, {'scalar'}))
    
    %/ run parser
    parse(params, varargin{:})
end