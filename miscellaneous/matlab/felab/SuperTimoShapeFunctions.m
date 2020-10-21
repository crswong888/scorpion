clear all %#ok<CLALL>
format longeng
fprintf('\n')

%// parameters
syms xi Omega J
C = sym('C', [4, 1]);


%%% Deflection in y-direction
%%% ------------------------------------------------------------------------------------------------

%// complementary solution of prismatic Timoshenko beam
v = Omega * C(1) * xi + C(1) * xi^3 / 6 + C(2) * xi^2 / 2 + C(3) * xi + C(4);
omega = -(C(1) * xi^2 / 2 + C(2) * xi + C(3));

%// nodal constraints for shape functions in natural coordinate system
qv = [subs(v, xi, -1); subs(omega, xi, -1); subs(v, xi, 1); subs(omega, xi, 1)];

%// get coefficients of C1,...,C4 in complementary solution
coefficients_v = [equationsToMatrix(v, C); equationsToMatrix(omega, C)];

%// get coefficents of C1,...,C4 nodal constraint system and invert
straints_v = equationsToMatrix(qv, C);
invstraints_v = inv(straints_v);

%// solve H = coefficients * C
Hv = simplify(coefficients_v * invstraints_v); %#ok<MINV>

%// evaluate the shape function derivatives
dHv = simplify(diff(Hv, xi));

%// check if simplified forms are equal
chkHv = Hv(1,:) == [2 - 6 * Omega - 3 * xi + 6 * Omega * xi + xi^3,...
                       -1 + 3 * Omega + xi + xi^2 - 3 * Omega * xi^2 - xi^3,...
                       2 - 6 * Omega + 3 * xi - 6 * Omega * xi - xi^3,...
                       1 - 3 * Omega + xi - xi^2 + 3 * Omega * xi^2 - xi^3] / (4 - 12 * Omega);

chkdHv = dHv(1,:) == [-3 + 6 * Omega + 3 * xi^2,...
                         1 + 2 * xi - 6 * Omega * xi - 3 * xi^2,...
                         3 - 6 * Omega - 3 * xi^2,...
                         1 - 2 * xi + 6 * Omega * xi - 3 * xi^2] / (4 - 12 * Omega);
                    
chkHomega = Hv(2,:) == [3 - 3 * xi^2,...
                           -1 - 6 * Omega - 2 * xi + 6 * Omega * xi + 3 * xi^2,...
                           -3 + 3 * xi^2,...
                           -1 - 6 * Omega + 2 * xi - 6 * Omega * xi + 3 * xi^2] / (4 - 12 * Omega);
                        
chkdHomega = dHv(2,:) == [-3 * xi,...
                             -1 + 3 * Omega + 3 * xi,...
                             3 * xi,...
                             1 - 3 * Omega + 3 * xi] / (2 - 6 * Omega);
                         
chkHv = simplify(subs(chkHv, [xi, Omega], [0.5, 12]));
chkdHv = simplify(subs(chkdHv, [xi, Omega], [0.5, 12]));
chkHomega = simplify(subs(chkHomega, [xi, Omega], [0.5, 12]));
chkdHomega = simplify(subs(chkdHomega, [xi, Omega], [0.5, 12]));

%%% Deflection in z-direction
%%% ------------------------------------------------------------------------------------------------

%// complementary solution of prismatic Timoshenko beam
w = -Omega * C(1) / J * xi + J * (C(1) * xi^3 / 6 + C(2) * xi^2 / 2 + C(3) * xi + C(4));
phi = -(C(1) * xi^2 / 2 + C(2) * xi + C(3));

%// nodal constraints for shape functions in natural coordinate system
qw = [subs(w, xi, -1); subs(phi, xi, -1); subs(w, xi, 1); subs(phi, xi, 1)];

%// get coefficients of C1,...,C4 in complementary solution
coefficients_w = [equationsToMatrix(w, C); equationsToMatrix(phi, C)];

%// get coefficents of C1,...,C4 nodal constraint system and invert
straints_w = equationsToMatrix(qw, C);
invstraints_w = inv(straints_w);

%// solve H = coefficients * C
Hw = simplify(coefficients_w * invstraints_w); %#ok<MINV>

%// evaluate the shape function derivatives
dHw = simplify(diff(Hw, xi));

%// check if simplified forms are equal
chkHw = Hw(1,:)... 
        == 1 / (4 * J^2 + 12 * Omega)...
           * [2 * J^2 + 6 * Omega - 3 * J^2 * xi - 6 * Omega * xi + J^2 * xi^3,...
              -J^3 - 3 * Omega * J + J^3 * xi + J^3 * xi^2 + 3 * Omega * J * xi^2 - J^3 * xi^3,...
              2 * J^2 + 6 * Omega + 3 * J^2 * xi + 6 * Omega * xi - J^2 * xi^3,...
              J^3 + 3 * Omega * J + J^3 * xi - J^3 * xi^2 - 3 * Omega * J * xi^2 - J^3 * xi^3];

chkdHw = dHw(1,:)...
         == 1 / (4 * J^2 + 12 * Omega)...
            * [-3 * J^2 - 6 * Omega + 3 * J^2 * xi^2,...
               J^3 + 2 * J^3 * xi + 6 * Omega * J * xi - 3 * J^3 * xi^2,...
               3 * J^2 + 6 * Omega - 3 * J^2 * xi^2,...
               J^3 - 2 * J^3 * xi - 6 * Omega * J * xi - 3 * J^3 * xi^2];
                    
chkHphi = Hw(2,:)...
          == 1 / (4 * J^2 + 12 * Omega)...
             * [3 * J - 3 * J * xi^2,...
                -J^2 + 6 * Omega - 2 * J^2 * xi - 6 * Omega * xi + 3 * J^2 * xi^2,...
                -3 * J + 3 * J * xi^2,...
                -J^2 + 6 * Omega + 2 * J^2 * xi + 6 * Omega * xi + 3 * J^2 * xi^2];
                        
chkdHphi = dHw(2,:)...
           == 1 / (2 * J^2 + 6 * Omega)...
              * [-3 * J * xi,...
                 -J^2 - 3 * Omega + 3 * J^2 * xi,...
                 3 * J * xi,...
                 J^2 + 3 * Omega + 3 * J^2 * xi];
                       
chkHw = simplify(subs(chkHw, [xi, Omega, J], [-0.25, 27, 175]));
chkdHw = simplify(subs(chkdHw, [xi, Omega, J], [-0.25, 27, 175]));
chkHphi = simplify(subs(chkHphi, [xi, Omega, J], [-0.25, 27, 175]));
chkdHphi = simplify(subs(chkdHphi, [xi, Omega, J], [-0.25, 27, 175]));

%%% note use polynomialDegree() to check the order, also clipboard('copy', latex()) is helpful



% %// complementary solution of prismatic Timoshenko beam
% v = -Omega * C(1) * xi -(C(1) * xi^3 / 6 + C(2) * xi^2 / 2 + C(3) * xi + C(4));
% omega = -(C(1) * xi^2 / 2 + C(2) * xi + C(3));
% 
% %// nodal constraints for shape functions in natural coordinate system
% qv = [subs(v, xi, -1); subs(omega, xi, -1); subs(v, xi, 1); subs(omega, xi, 1)];
% 
% %// get coefficients of C1,...,C4 in complementary solution
% coefficients_v = [equationsToMatrix(v, C); equationsToMatrix(omega, C)];
% 
% %// get coefficents of C1,...,C4 nodal constraint system and invert
% straints_v = equationsToMatrix(qv, C);
% invstraints_v = inv(straints_v);
% 
% %// solve H = coefficients * C
% Hv = simplify(coefficients_v * invstraints_v); %#ok<MINV>
% 
% %// evaluate the shape function derivatives
% dHv = simplify(diff(Hv, xi));
% 
% %// check if simplified forms are equal
% chkHv = Hv(1,:) == [2 - 6 * Omega - 3 * xi + 6 * Omega * xi + xi^3,...
%                        1 - 3 * Omega - xi - xi^2 + 3 * Omega * xi^2 + xi^3,...
%                        2 - 6 * Omega + 3 * xi - 6 * Omega * xi - xi^3,...
%                        -1 + 3 * Omega - xi + xi^2 - 3 * Omega * xi^2 + xi^3] / (4 - 12 * Omega);
% 
% chkdHv = dHv(1,:) == [-3 + 6 * Omega + 3 * xi^2,...
%                          -1 - 2 * xi + 6 * Omega * xi + 3 * xi^2,...
%                          3 - 6 * Omega - 3 * xi^2,...
%                          -1 + 2 * xi - 6 * Omega * xi + 3 * xi^2] / (4 - 12 * Omega);
%                     
% chkHomega = Hv(2,:) == [-3 + 3 * xi^2,...
%                            -1 - 6 * Omega - 2 * xi + 6 * Omega * xi + 3 * xi^2,...
%                            3 - 3 * xi^2,...
%                            -1 - 6 * Omega + 2 * xi - 6 * Omega * xi + 3 * xi^2] / (4 - 12 * Omega);
%                         
% chkdHomega = dHv(2,:) == [3 * xi,...
%                              -1 + 3 * Omega + 3 * xi,...
%                              -3 * xi,...
%                              1 - 3 * Omega + 3 * xi] / (2 - 6 * Omega);
%                          
% chkHv = simplify(subs(chkHv, [xi, Omega], [0.5, 12]));
% chkdHv = simplify(subs(chkdHv, [xi, Omega], [0.5, 12]));
% chkHomega = simplify(subs(chkHomega, [xi, Omega], [0.5, 12]));
% chkdHomega = simplify(subs(chkdHomega, [xi, Omega], [0.5, 12]));