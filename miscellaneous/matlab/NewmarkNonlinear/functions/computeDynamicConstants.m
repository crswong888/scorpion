%%% This function consolidates three basic calculations: elastic stiffness (slope of the intitial
%%% segment of the backbone curve), natural frequency, and viscous damping coefficient.
%%%
%%% By: Christopher Wong | crswong888@gmail.com

function [omega_n, c, ke] = computeDynamicConstants(m, xi, fs)
    %// assert that backbone curve does not begin at (0, 0)
    if (all(fs(:,1) == [0; 0]))
        error(['The first abscissa-oridnate pair of the supplied backbone curve data is ',...
               '''[0; 0]''. Please provide some other point in the upper positive quadrant.'])
    end

    %// elastic stiffness
    ke = fs(2,1) / fs(1,1);

    %// natural frequency of elastic system
    omega_n = sqrt(ke / m);

    %// compute damping coefficient (assumed to be constant even if plastic)
    c = 2 * xi * m * omega_n;
end