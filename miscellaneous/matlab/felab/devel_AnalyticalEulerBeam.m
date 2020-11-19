%%% trying to do stuff with distributed loads here - this code is very broken atm

clear all %#ok<CLALL>
format longeng
fprintf('\n')

%// input nodal rotation and displacement BCs (NaN = not prescribed)
du0 = [ 0 ; NaN] ; 
u0 = [ 0 ; NaN] ;

load_func = true;
wx = {@(x) sin(2 * pi * x / 325)};

%%% run the following to get the fixed-end reactions:
%%% R1 = double(subs(sol.R1, L(1), 650))
%%% MR1 = double(subs(sol.MR1, L(1), 650))
%%% R2 = double(subs(sol.R2, L(1), 650))
%%% MR2 = double(subs(sol.MR2, L(1), 650)) 

%%% devel - this reproduces AISC for case 18 by running subs(sol.R2, [P(1), sym('ell')], [0, L(1)])
% du0 = [ NaN ; 0] ; 
% u0 = [ NaN ; 0] ;
% load_func = true;
% wx = {@(x) 2 * sym('W') / sym('ell')^2 * x};

%// intitialize variable symbols
syms x
%/ nodal information
N = length(u0) ; % number of nodes
P = sym('P', [N 1]) ;
R = sym('R', [N 1]) ;
M = sym('M', [N 1]) ;
MR = sym('MR', [N 1]) ;
%/ beam span information
Ne = N - 1 ; % number of beam spans
E = sym('E', [Ne 1]) ;
I = sym('I', [Ne 1]) ;
L = sym('L', [Ne 1]) ;
C = sym('C', [Ne 4]) ; % row: shear, moment, rotation, and displacement constants - per beam

%// initialize euler-bernoulli beam equation
u = sym(zeros(Ne,1)) ; du = sym(zeros(Ne,1)) ; d2u = sym(zeros(Ne,1)) ; d3u = sym(zeros(Ne,1)) ;
if (~load_func)
    w = sym('w', [Ne 1]) ;
    for e = 1:Ne
        d3u(e) = 1 / (E(e) * I(e)) * (w(e) * x + C(e, 1)) ;
        d2u(e) = 1 / (E(e) * I(e)) * (w(e) * x^2 / 2 + C(e,1) * x + C(e,2)) ;
        du(e) = 1 / (E(e) * I(e)) * (w(e) * x^3 / 6 + C(e,1) * x^2 / 2 + C(e,2) * x + C(e,3)) ;
        u(e) = 1 / (E(e) * I(e)) * (w(e) * x^4 / 24 + C(e,1) * x^3 / 6 + C(e,2) * x^2 / 2 + ...
               C(e,3) * x + C(e,4)) ;
    end
    
    syms w(x) [Ne 1]
    wx = @(x) sym('w');
else
    %/ have to first create symfuns for symbolic integrals, then substitute 'wx' in
    syms w(x) [Ne 1]
    w = formula(w);
    for e = 1:Ne
        d3u(e) = 1 / (E(e) * I(e)) * (int(w(e)) + C(e, 1));
        d2u(e) = 1 / (E(e) * I(e)) * (int(int(w(e))) + C(e,1) * x + C(e,2));
        du(e) = 1 / (E(e) * I(e)) * (int(int(int(w(e)))) + C(e,1) * x^2 / 2 + C(e,2) * x + C(e,3));
        u(e) = 1 / (E(e) * I(e)) * (int(int(int(int(w(e))))) + C(e,1) * x^3 / 6 + ...
               C(e,2) * x^2 / 2 + C(e,3) * x + C(e,4));
        
    end
    
    %/ substitute provided function
    syms w(x) [Ne 1]
    d3u = subs(d3u, w, wx);
    d2u = subs(d2u, w, wx);
    du = subs(du, w, wx);
    u = subs(u, w, wx);
end

%// initialize the boundary value problem
%/ set domain lower bound to x = 0 and set the dirichlet and neumann BCs at node 1
BVP = [ E(1) * I(1) * subs(d3u(1), x, 0) == P(1) + R(1) ;
        E(1) * I(1) * subs(d2u(1), x, 0) == -M(1) - MR(1) ] ;
if (~isnan(du0(1))), BVP = cat(1, BVP, subs(du(1), x, 0) == du0(1)) ; end
if (~isnan(u0(1))), BVP = cat(1, BVP, subs(u(1), x, 0) == u0(1)) ; end
for e = 2:Ne
    %/ set the dirichlet and neumann BCs at each beam lower bound node and enforce conservation
    x0 = sum(L(1:e-1)) ; % location of lower bound node of current beam
    BVP = cat(1, BVP, ...
              [ E(e) * I(e) * subs(d3u(e), x, x0) == E(e-1) * I(e-1) * subs(d3u(e-1), x, x0) + P(e) + R(e) ;
                E(e) * I(e) * subs(d2u(e), x, x0) == E(e-1) * I(e-1) * subs(d2u(e-1), x, x0) - M(e) - MR(e) ;
                subs(du(e), x, x0) == subs(du(e-1), x, x0) ;
                subs(u(e), x, x0) == subs(u(e-1), x, x0) ]) ;
    if (~isnan(du0(e))), BVP = cat(1, BVP, subs(du(e), x, x0) == du0(e)) ; end
    if (~isnan(u0(e))), BVP = cat(1, BVP, subs(u(e), x, x0) == u0(e)) ; end
end
%/ set the dirichlet BCs at the upper bound node
if (~isnan(du0(Ne+1))), BVP = cat(1, BVP, subs(du(Ne), x, sum(L)) == du0(Ne+1)) ; end
if (~isnan(u0(Ne+1))), BVP = cat(1, BVP, subs(u(Ne), x, sum(L)) == u0(Ne+1)) ; end
%/ enforce principally static equilibrium
BVP = cat(1, BVP, sum(P) + sum(R) + subs(int(w, [0; L(1:e-1)], L), w, wx) == 0) ;

%%% definitely need a cleaner code to handle summation of moments, but this 1 element case is right
%/ enforce rotationally static equilibrium
centroid = subs(int(w * x, 0, L(1)), w, wx) / subs(int(w, 0, L(1)), w, wx);
sumM = M(1) + MR(1) + subs(int(w, 0, L(1)), w, wx) * centroid ; % initialize

%%% devel: this for-loop is broken! defininition of w has been changed...
for e = 2:Ne
    sumM = sumM + (P(e) + R(e) + w(e) * L(e)) * sum(L(1:e-1)) + w(e) * L(e)^2 / 2 + M(e) + MR(e) ;
end, sumM = sumM + (P(Ne+1) + R(Ne+1)) * sum(L) + M(Ne+1) + MR(Ne+1) ;
BVP = cat(1, BVP, sumM == 0) ;

%// solve the system of equations resulting from the boundary value problem
%/ determine which reactions exist, remove point forces at restraints
rxns = [] ;
for i = 1:N 
    if (isnan(u0(i))), BVP = subs(BVP, R(i), 0) ; 
    else, rxns = cat(1, rxns, R(i)) ; BVP = subs(BVP, P(i), 0) ; end 
    if (isnan(du0(i))), BVP = subs(BVP, MR(i), 0) ; 
    else, rxns = cat(1, rxns, MR(i)) ; BVP = subs(BVP, M(i), 0) ; end
end
sol = solve(BVP, [rxns ; C(:)]) ;


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

subsC = [sol.C1, sol.C2, sol.C3, sol.C4];
ux = subs(u, C, subsC);
dux = subs(du, C, subsC);
Mx = subs(E * I * d2u, C, subsC);
Vx = subs(E * I * d3u, C, subsC);

ux = subs(ux, [P; M; L; E; I], [0; 0; 0; 0; 650; 20e3; 96e3]);
dux = subs(dux, [P; M; L; E; I], [0; 0; 0; 0; 650; 20e3; 96e3]);
Mx = subs(Mx, [P; M; L], [0; 0; 0; 0; 650]);
Vx = subs(Vx, [P; M; L], [0; 0; 0; 0; 650]);

ds = 650 / 11;
n = 650 / ds + 1;
displacements = zeros(n, 1);
rotations = zeros(n, 1);
for i = 1:n
    s = ds * (i - 1);
    displacements(i) = double(subs(ux, x, s));
    rotations(i) = double(subs(dux, x, s));
end

figure(1)
fplot(ux, [0, 650]) 

figure(2)
fplot(dux, [0, 650]) 

figure(3)
fplot(Mx, [0, 650]) 

figure(4)
fplot(Vx, [0, 650]) 