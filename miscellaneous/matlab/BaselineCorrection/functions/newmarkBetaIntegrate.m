%%% This function twice numerically integrates an acceleration over a single time interval using the
%%% Newmark-beta method.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function u = newmarkBetaIntegrate(dt, d2u_old, d2u, du_old, u_old, beta)
    u = u_old + dt * du_old + (0.5 - beta) * dt * dt * d2u_old + beta * dt * dt * d2u;
end