%%% This function twice numerically integrates an acceleration to obtain a velocity and a
%%% displacement time series using the Newmark-beta method.	
%%%	
%%% By: Christopher Wong | crswong888@gmail.com	

function [du, u] = newmarkIntegrate(t, d2u, gamma, beta)
    N = length(d2u);
    du = zeros(1, N);
    u = zeros(1, N);
    for i = 1:(N - 1)
        dt = t(i + 1) - t(i);
        
        %/ update velocity
        du(i + 1) = du(i) + (1 - gamma) * dt * d2u(i) + gamma * dt * d2u(i + 1);
        
        %/ update displacement
        u(i + 1) = u(i) + dt * du(i) + (0.5 - beta) * dt * dt * d2u(i)...
                   + beta * dt * dt * d2u(i + 1);
    end
end