clear all %#ok<CLALL>
format longeng
fprintf('\n')

%// parameters
syms xi Omega L
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
check_Hv = Hv(1,:) == [2 - 6 * Omega - 3 * xi + 6 * Omega * xi + xi^3,...
                       -1 + 3 * Omega + xi + xi^2 - 3 * Omega * xi^2 - xi^3,...
                       2 - 6 * Omega + 3 * xi - 6 * Omega * xi - xi^3,...
                       1 - 3 * Omega + xi - xi^2 + 3 * Omega * xi^2 - xi^3] / (4 - 12 * Omega);

check_dHv = dHv(1,:) == [-3 + 6 * Omega + 3 * xi^2,...
                         1 + 2 * xi - 6 * Omega * xi - 3 * xi^2,...
                         3 - 6 * Omega - 3 * xi^2,...
                         1 - 2 * xi + 6 * Omega * xi - 3 * xi^2] / (4 - 12 * Omega);
                    
check_Homega = Hv(2,:) == [3 - 3 * xi^2,...
                           -1 - 6 * Omega - 2 * xi + 6 * Omega * xi + 3 * xi^2,...
                           -3 + 3 * xi^2,...
                           -1 - 6 * Omega + 2 * xi - 6 * Omega * xi + 3 * xi^2] / (4 - 12 * Omega);
                        
check_dHomega = dHv(2,:) == [-3 * xi,...
                             -1 + 3 * Omega + 3 * xi,...
                             3 * xi,...
                             1 - 3 * Omega + 3 * xi] / (2 - 6 * Omega);
                         
check_Hv = simplify(subs(check_Hv, [xi, Omega], [0.5, 12]));
check_dHv = simplify(subs(check_dHv, [xi, Omega], [0.5, 12]));
check_Homega = simplify(subs(check_Homega, [xi, Omega], [0.5, 12]));
check_dHomega = simplify(subs(check_dHomega, [xi, Omega], [0.5, 12]));

%%% Deflection in z-direction
%%% ------------------------------------------------------------------------------------------------

%// complementary solution of prismatic Timoshenko beam
w = -Omega * C(1) * xi + C(1) * xi^3 / 6 + C(2) * xi^2 / 2 + C(3) * xi + C(4);
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
check_Hw = Hw(1,:) == [2 + 6 * Omega - 3 * xi - 6 * Omega * xi + xi^3,...
                       -1 - 3 * Omega + xi + xi^2 + 3 * Omega * xi^2 - xi^3,...
                       2 + 6 * Omega + 3 * xi + 6 * Omega * xi - xi^3,...
                       1 + 3 * Omega + xi - xi^2 - 3 * Omega * xi^2 - xi^3] / (4 + 12 * Omega);

check_dHw = dHw(1,:) == [-3 - 6 * Omega + 3 * xi^2,...
                         1 + 2 * xi + 6 * Omega * xi - 3 * xi^2,...
                         3 + 6 * Omega - 3 * xi^2,...
                         1 - 2 * xi - 6 * Omega * xi - 3 * xi^2] / (4 + 12 * Omega);
                    
check_Hphi = Hw(2,:) == [3 - 3 * xi^2,...
                         -1 + 6 * Omega - 2 * xi - 6 * Omega * xi + 3 * xi^2,...
                         -3 + 3 * xi^2,...
                         -1 + 6 * Omega + 2 * xi + 6 * Omega * xi + 3 * xi^2] / (4 + 12 * Omega);
                        
check_dHphi = dHw(2,:) == [-3 * xi,...
                           -1 - 3 * Omega + 3 * xi,...
                           3 * xi,...
                           1 + 3 * Omega + 3 * xi] / (2 + 6 * Omega);
                       
check_Hw = simplify(subs(check_Hw, [xi, Omega], [-0.25, 27]));
check_dHw = simplify(subs(check_dHw, [xi, Omega], [-0.25, 27]));
check_Hphi = simplify(subs(check_Hphi, [xi, Omega], [-0.25, 27]));
check_dHphi = simplify(subs(check_dHphi, [xi, Omega], [-0.25, 27]));

%%% note use polynomialDegree() to check the order



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
% check_Hv = Hv(1,:) == [2 - 6 * Omega - 3 * xi + 6 * Omega * xi + xi^3,...
%                        1 - 3 * Omega - xi - xi^2 + 3 * Omega * xi^2 + xi^3,...
%                        2 - 6 * Omega + 3 * xi - 6 * Omega * xi - xi^3,...
%                        -1 + 3 * Omega - xi + xi^2 - 3 * Omega * xi^2 + xi^3] / (4 - 12 * Omega);
% 
% check_dHv = dHv(1,:) == [-3 + 6 * Omega + 3 * xi^2,...
%                          -1 - 2 * xi + 6 * Omega * xi + 3 * xi^2,...
%                          3 - 6 * Omega - 3 * xi^2,...
%                          -1 + 2 * xi - 6 * Omega * xi + 3 * xi^2] / (4 - 12 * Omega);
%                     
% check_Homega = Hv(2,:) == [-3 + 3 * xi^2,...
%                            -1 - 6 * Omega - 2 * xi + 6 * Omega * xi + 3 * xi^2,...
%                            3 - 3 * xi^2,...
%                            -1 - 6 * Omega + 2 * xi - 6 * Omega * xi + 3 * xi^2] / (4 - 12 * Omega);
%                         
% check_dHomega = dHv(2,:) == [3 * xi,...
%                              -1 + 3 * Omega + 3 * xi,...
%                              -3 * xi,...
%                              1 - 3 * Omega + 3 * xi] / (2 - 6 * Omega);
%                          
% check_Hv = simplify(subs(check_Hv, [xi, Omega], [0.5, 12]));
% check_dHv = simplify(subs(check_dHv, [xi, Omega], [0.5, 12]));
% check_Homega = simplify(subs(check_Homega, [xi, Omega], [0.5, 12]));
% check_dHomega = simplify(subs(check_dHomega, [xi, Omega], [0.5, 12]));