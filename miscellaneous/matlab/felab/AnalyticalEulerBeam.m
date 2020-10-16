clear all
format longeng
fprintf('\n') % Command Window output formatting

%// input nodal rotation and displacement BCs (NaN = not prescribed)
du0 = [ NaN ; 0 ] ; 
u0 = [ 0 ; 0 ] ;

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
w = sym('w', [Ne 1]) ;
C = sym('C', [Ne 4]) ; % row: shear, moment, rotation, and displacement constants - per beam

%// initialize euler-bernoulli beam equation
u = sym(zeros(Ne,1)) ; du = sym(zeros(Ne,1)) ; d2u = sym(zeros(Ne,1)) ; d3u = sym(zeros(Ne,1)) ;
for e = 1:Ne
    d3u(e) = 1 / (E(e) * I(e)) * (w(e) * x + C(e)) ;
    d2u(e) = 1 / (E(e) * I(e)) * (w(e) * x^2 / 2 + C(e,1) * x + C(e,2)) ;
    du(e) = 1 / (E(e) * I(e)) * (w(e) * x^3 / 6 + C(e,1) * x^2 / 2 + C(e,2) * x + C(e,3)) ;
    u(e) = 1 / (E(e) * I(e)) * (w(e) * x^4 / 24 + C(e,1) * x^3 / 6 + C(e,2) * x^2 / 2 + ...
           C(e,3) * x + C(e,4)) ;
end

%// initialize the boundary value problem
%/ set domain lower bound to x = 0 and set the dirichlet and neumann BCs at node 1
BVP = [ subs(d3u(1), x, 0) == (P(1) + R(1)) / (E(1) * I(1)) ;
        subs(d2u(1), x, 0) == - (M(1) + MR(1)) / (E(1) * I(1)) ] ;
if (~isnan(du0(1))), BVP = cat(1, BVP, subs(du(1), x, 0) == du0(1)) ; end
if (~isnan(u0(1))), BVP = cat(1, BVP, subs(u(1), x, 0) == u0(1)) ; end
for e = 2:Ne
    %/ set the dirichlet and neumann BCs at each beam lower bound node and enforce conservation
    x0 = sum(L(1:e-1)) ; % location of lower bound node of current beam
    BVP = cat(1, BVP, ...
              [ subs(d3u(e), x, x0) == subs(d3u(e-1), x, x0) + (P(e) + R(e)) / (E(e) * I(e)) ;
                subs(d2u(e), x, x0) == subs(d2u(e-1), x, x0) - (M(e) + MR(e)) / (E(e) * I(e)) ;
                subs(du(e), x, x0) == subs(du(e-1), x, x0) ;
                subs(u(e), x, x0) == subs(du(e-1), x, x0) ]) ;
    if (~isnan(du0(e))), BVP = cat(1, BVP, subs(du(e), x, x0) == du0(e)) ; end
    if (~isnan(u0(e))), BVP = cat(1, BVP, subs(u(e), x, x0) == u0(e)) ; end
end
%/ set the dirichlet BCs at the upper bound node
if (~isnan(du0(Ne+1))), BVP = cat(1, BVP, subs(du(Ne), x, sum(L)) == du0(Ne+1)) ; end
if (~isnan(u0(Ne+1))), BVP = cat(1, BVP, subs(u(Ne), x, sum(L)) == u0(Ne+1)) ; end
%/ enforce principally static equilibrium
BVP = cat(1, BVP, sum(P) + sum(R) + transpose(w) * L == 0) ;
%/ enforce rotationally static equilibrium
sumM = M(1) + MR(1) + w(1) * L(1)^2 / 2 ; % initialize
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