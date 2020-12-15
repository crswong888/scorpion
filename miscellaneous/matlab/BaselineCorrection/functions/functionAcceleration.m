%%% This function generates an acceleration time history using an ordinary function handle of time.
%%% The time domain is discretized at regular intervals of 'dt' and the 'accel_func' is evaluated at
%%% those grid points.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function [t, d2u] = functionAcceleration(start_time, end_time, dt, accel_func)
    %// assert that 'accel_func' is an anonymous function
    if (~isa(accel_func, 'function_handle'))
        error(['The ''accel_func'' parameter must be an anonymous function variable, e.g., ',...
               '''accel_func = @(t) sin(t)''.'])
    end

    %// generate array of discrete time instances
    [t, N] = generate1DGridPoints(start_time, end_time, dt);
    
    %// evaluate acceleration function at time points
    d2u = zeros(1, N);
    for i = 1:N
        d2u(i) = accel_func(t(i));
    end
end