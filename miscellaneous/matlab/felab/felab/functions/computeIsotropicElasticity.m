function D = computeIsotropicElasticity(E, nu)
    
    %// compute the stress-strain compatibility matrix for the case of 3D isotropic elasticity
    lambda = E * nu / ((1 + nu) * (1 - 2 * nu)); % Lame's first constant
    D = lambda / nu * [1 - nu,     nu,     nu,          0,          0,          0;
                           nu, 1 - nu,     nu,          0,          0,          0;
                           nu,     nu, 1 - nu,          0,          0,          0;
                            0,      0,      0, 1 / 2 - nu,          0,          0;
                            0,      0,      0,          0, 1 / 2 - nu,          0;
                            0,      0,      0,          0,          0, 1 / 2 - nu];

end