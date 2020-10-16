clear all %#ok<CLALL>
format longeng
fprintf('\n')

P = 75;
L = norm([-2.8, 4, 2.8]);
b = 0.1;
h = 0.25;
A = b * h;
I = b * h^3 / 12;
rho = 8050;
g = 9.81;
w = rho * g * A;
E = 200e+06;
nu = 0.3;
G = E / (2 + 2 * nu);
kappa = 10 * (1 + nu) / (12 + 11 * nu); % for solid rectangular sections

pointLoadPinnedEuler = P * L^3 / (48 * E * I);
pointLoadPinnedTimoshenko = P * L / (4 * kappa * G * A) + P * L^3 / (48 * E * I);

distributedLoadPinnedEuler = 5 * w * L^4 / (384 * E * I);
distributedLoadPinnedTimoshenko = w * L^2 / (8 * kappa * G * A) + 5 * w * L^4 / (384 * E * I);

pointLoadFixedEuler = P * L^3 / (192 * E * I);
pointLoadFixedTimoshenko = P * L / (4 * kappa * G * A) + P * L^3 / (192 * E * I);

distributedLoadFixedEuler = w * L^4 / (384 * E * I);
distributedLoadFixedTimoshenko = w * L^2 / (8 * kappa * G * A) + w * L^4 / (384 * E * I);