%%% This function consolidates three basic calculations: elastic stiffness (slope of the intitial
%%% segment of the backbone curve), natural frequency, and viscous damping coefficient.
%%% 
%%% By: Christopher Wong | crswong888@gmail.com

function [omega_n, c, ke] = computeDynamicConstants(m, zeta, fs)
    %// validate required inputs
    validateattributes(m, {'numeric'}, {'scalar', 'positive'}, 1)
    validateattributes(zeta, {'numeric'}, {'scalar', 'nonnegative', '<=', 1}, 2)
    
    %/ data for backbone curve must be exclusively positive so it can be reflected about origin
    validateattributes(fs, {'numeric'}, {'nrows', 2, 'positive'}, 3)
    
    %// elastic spring stiffness
    ke = fs(2,1) / fs(1,1);
    
    %// natural angular frequency of elastic system
    omega_n = sqrt(ke / m);
    
    %// viscous damping coefficient (assumed to be constant even if spring yields)
    c = 2 * zeta * m * omega_n;
end