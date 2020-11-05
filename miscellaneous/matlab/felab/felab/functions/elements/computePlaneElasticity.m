%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FE Environment for Solid Mechanics %%%
%%%        By: Christopher Wong        %%%
%%%        crswong888@gmail.com        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function D = computePlaneElasticity(E, nu, formulation)
    %// parse the formulation input to ensure clarity on wether to use Plane Stress or Plane Strain
    params = inputParser; % create instance to access the inputParser class
    addRequired(params, 'formulation', @(x) any(validatestring(x, {'PlaneStress', 'PlaneStrain'})));
    parse(params, formulation) % parse the inputs into the class instance
    
    %// Compute the stress-strain compatibility matrix according to specified formulation
    if (strcmp(params.Results.formulation, 'PlaneStress'))
        D = E / (1 - nu^2) * [ 1, nu,            0;   % stress_zz
                              nu,  1,            0;   % stress_yy
                               0,  0, (1 - nu) / 2]; % 2 * stress_xy
    else
        lambda = E * nu / ((1 + nu) * (1 - 2 * nu)); % Lame's first constant
        D = lambda / nu * [1 - nu,     nu, 0,                0;   % stress_xx
                               nu, 1 - nu, 0,                0;   % stress_yy
                               nu,     nu, 0,                0;   % stress_zz
                                0,      0, 0, (1 - 2 * nu) / 2]; % 2 * stress_xy
    end
end