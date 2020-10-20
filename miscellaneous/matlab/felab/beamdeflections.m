clear all %#ok<CLALL>
format longeng
fprintf('\n')

P = 125;
L = 700; % cm
b = 18; % cm
h = 40; % cm
A = b * h; % cm^2
I = b * h^3 / 12; % cm^4
w = 0;
E = 200e+09 / 10e+06; % kN / cm^2
nu = 0.3;
G = E / (2 + 2 * nu); % kN / cm^2
kappa = 10 * (1 + nu) / (12 + 11 * nu); % for solid rectangular sections

pointLoadPinnedEuler = P * L^3 / (48 * E * I);
pointLoadPinnedTimoshenko = P * L / (4 * kappa * G * A) + P * L^3 / (48 * E * I);

distributedLoadPinnedEuler = 5 * w * L^4 / (384 * E * I);
distributedLoadPinnedTimoshenko = w * L^2 / (8 * kappa * G * A) + 5 * w * L^4 / (384 * E * I);

pointLoadFixedEuler = P * L^3 / (192 * E * I);
pointLoadFixedTimoshenko = P * L / (4 * kappa * G * A) + P * L^3 / (192 * E * I);

distributedLoadFixedEuler = w * L^4 / (384 * E * I);
distributedLoadFixedTimoshenko = w * L^2 / (8 * kappa * G * A) + w * L^4 / (384 * E * I);