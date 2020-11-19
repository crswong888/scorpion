clear all
format longeng
fprintf('\n') % Command Window output formatting

%// input nodal rotation and displacement BCs (NaN = not prescribed)
du0 = [ NaN ; NaN ; NaN ] ; 
u0 = [ 0 ; NaN ; 0 ] ;

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
    d3u(e) = 1 / (E(e) * I(e)) * (w(e) * x + C(e,1)) ;
    d2u(e) = 1 / (E(e) * I(e)) * (w(e) * x^2 / 2 + C(e,1) * x + C(e,2)) ;
    du(e) = 1 / (E(e) * I(e)) * (w(e) * x^3 / 6 + C(e,1) * x^2 / 2 + C(e,2) * x + C(e,3)) ;
    u(e) = 1 / (E(e) * I(e)) * (w(e) * x^4 / 24 + C(e,1) * x^3 / 6 + C(e,2) * x^2 / 2 + ...
           C(e,3) * x + C(e,4)) ;
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


%%% POSTPROCESSING
%%% ------------------------------------------------------------------------------------------------

R1x = subs(sol.R1, [w; L; P(2); M], [sym('w') * ones(2, 1); sym('L') / 2 * ones(2, 1); sym('P'); 0; 0; 0]);
R3x = subs(sol.R3, [w; L; P(2); M], [sym('w') * ones(2, 1); sym('L') / 2 * ones(2, 1); sym('P'); 0; 0; 0]);
C11x = subs(sol.C1_1, [w; L; P(2); M; E; I], [sym('w') * ones(2, 1); sym('L') / 2 * ones(2, 1); sym('P'); 0; 0; 0; sym('E') * ones(2, 1); sym('I') * ones(2, 1)]);
C21x = subs(sol.C2_1, [w; L; P(2); M; E; I], [sym('w') * ones(2, 1); sym('L') / 2 * ones(2, 1); sym('P'); 0; 0; 0; sym('E') * ones(2, 1); sym('I') * ones(2, 1)]);
C12x = subs(sol.C1_2, [w; L; P(2); M; E; I], [sym('w') * ones(2, 1); sym('L') / 2 * ones(2, 1); sym('P'); 0; 0; 0; sym('E') * ones(2, 1); sym('I') * ones(2, 1)]);
C22x = subs(sol.C2_2, [w; L; P(2); M; E; I], [sym('w') * ones(2, 1); sym('L') / 2 * ones(2, 1); sym('P'); 0; 0; 0; sym('E') * ones(2, 1); sym('I') * ones(2, 1)]);
C13x = subs(sol.C1_3, [w; L; P(2); M; E; I], [sym('w') * ones(2, 1); sym('L') / 2 * ones(2, 1); sym('P'); 0; 0; 0; sym('E') * ones(2, 1); sym('I') * ones(2, 1)]);
C23x = subs(sol.C2_3, [w; L; P(2); M; E; I], [sym('w') * ones(2, 1); sym('L') / 2 * ones(2, 1); sym('P'); 0; 0; 0; sym('E') * ones(2, 1); sym('I') * ones(2, 1)]);
C14x = subs(sol.C1_4, [w; L; P(2); M; E; I], [sym('w') * ones(2, 1); sym('L') / 2 * ones(2, 1); sym('P'); 0; 0; 0; sym('E') * ones(2, 1); sym('I') * ones(2, 1)]);
C24x = subs(sol.C2_4, [w; L; P(2); M; E; I], [sym('w') * ones(2, 1); sym('L') / 2 * ones(2, 1); sym('P'); 0; 0; 0; sym('E') * ones(2, 1); sym('I') * ones(2, 1)]);

subsC = [C11x, C12x, C13x, C14x; C21x, C22x, C23x, C24x];
ux = simplify(subs(u, [C, E, I, w], [subsC, sym('E') * ones(2, 1), sym('I') * ones(2, 1), sym('w') * ones(2, 1)]));
dux = simplify(subs(du, [C, E, I, w], [subsC, sym('E') * ones(2, 1), sym('I') * ones(2, 1), sym('w') * ones(2, 1)]));
Mx = simplify(subs(d2u .* (E .* I), [C, w], [subsC, sym('w') * ones(2, 1)]));
Vx = simplify(subs(d3u .* (E .* I), [C, w], [subsC, sym('w') * ones(2, 1)]));

R1 = subs(R1x, [sym('w'), sym('P'), sym('L'), sym('E'), sym('I')], [-0.25, -175, 650, 20e+03, 96e+03]);
R3 = subs(R3x, [sym('w'), sym('P'), sym('L'), sym('E'), sym('I')], [-0.25, -175, 650, 20e+03, 96e+03]);
u = simplify(subs(ux, [sym('w'), sym('P'), sym('L'), sym('E'), sym('I')], [-0.25, -175, 650, 20e+03, 96e+03]));
du = simplify(subs(dux, [sym('w'), sym('P'), sym('L'), sym('E'), sym('I')], [-0.25, -175, 650, 20e+03, 96e+03]));
M = simplify(subs(Mx, [sym('w'), sym('P'), sym('L')], [-0.25, -175, 650]));
V = simplify(subs(Vx, [sym('w'), sym('P'), sym('L')], [-0.25, -175, 650]));

ds = 325 / 3;
n = 650 / ds + 1;
displacements = zeros(n, 1);
rotations = zeros(n, 1);
for i = 1:floor(n / 2)
    s = ds * (i - 1);
    displacements(i) = double(subs(u(1), x, s));
    rotations(i) = double(subs(du(1), x, s));
end
for i = (floor(n / 2 )+ 1):n
    s = ds * (i - 1);
    displacements(i) = double(subs(u(2), x, s));
    rotations(i) = double(subs(du(2), x, s));
end

figure(1)
fplot(u(1), [0, 325]) 
hold on 
fplot(u(2), [325, 650])

figure(2)
fplot(du(1), [0, 325]) 
hold on 
fplot(du(2), [325, 650])

figure(3)
fplot(M(1), [0, 325]) 
hold on 
fplot(M(2), [325, 650])

figure(4)
fplot(V(1), [0, 325]) 
hold on 
fplot(V(2), [325, 650])