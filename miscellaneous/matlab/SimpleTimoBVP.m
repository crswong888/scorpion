clear all

syms RA L P k G A E I

coeff = [   1   -1  0 ;
          L/2 -L/2  1 ;
            0    L -1 ] ;
        
coeff_inv = inv(coeff) ;
        
vec = [                                         P * L^2 / (8 * E * I) ;
                     P * L / (2 * k * G * A) + P * L^3 / (24 * E * I) ;
        (RA - P) * L / (k * G * A) - L^3 / (6 * E * I) * (RA + P / 2) ] ;
    
C = coeff_inv * vec ;
C = simplify(C) ;