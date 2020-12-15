%%% This function once numerically integrates an acceleration over a single time interval using the
%%% Newmark-beta method.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function du = newmarkGammaIntegrate(dt, d2u_old, d2u, du_old, gamma)
    du = du_old + (1 - gamma) * dt * d2u_old + gamma * dt * d2u;
end