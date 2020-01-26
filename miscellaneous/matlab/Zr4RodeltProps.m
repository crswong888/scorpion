clear all

P = 2500 ;
L = 128.8 ;
A = 19.0758 ;
rho = 6.0e-09 ;
g = 9810 ;
w = rho * g * A ;
E = 9.93e04 ;
nu = 0.37 ;
G = E / (2 - 2 * nu) ;
I = 245.0624 ;
kappa = 0.5392 ;

pointLoadPinnedEuler = P * L^3 / (48 * E * I) ;
pointLoadPinnedTimoshenko = P * L / (4 * kappa * G * A) + P * L^3 / (48 * E * I) ;

distributedLoadPinnedEuler = 5 * w * L^4 / (384 * E * I) ;
distributedLoadPinnedTimoshenko = w * L^2 / (8 * kappa * G * A) + 5 * w * L^4 / (384 * E * I) ;

pointLoadFixedEuler = P * L^3 / (192 * E * I) ;
pointLoadFixedTimoshenko = P * L / (4 * kappa * G * A) + P * L^3 / (192 * E * I) ;

distributedLoadFixedEuler = w * L^4 / (384 * E * I) ;
distributedLoadFixedTimoshenko = w * L^2 / (8 * kappa * G * A) + w * L^4 / (384 * E * I) ;