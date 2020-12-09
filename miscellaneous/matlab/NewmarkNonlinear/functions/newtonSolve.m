%%% Attempts to solve an equation, f(x) = 0, using the Newton-Raphson method with finite difference.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function root = newtonSolve(f, interval, max_it, R_tol)
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
            fprintf('Newton solver converged at R = %g with %d iterations.\n\n', R, n)
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