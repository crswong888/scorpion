clear all %#ok<CLALL>
format longeng
fprintf('\n')


%// parameters
syms w(x) p(x) dp(x) L u1 r1 u2 r2 EI
C = sym('C', [4, 1]);

u = p + [x^3 / 6, x^2 / 2, x, 1] * C;
du = dp + [x^2 / 2, x, 1, 0] * C;

q = [subs(u, x, 0); subs(du, x, 0); subs(u, x, L); subs(du, x, L)];
intco = equationsToMatrix(q, C);
Csol = inv(intco) * (q - intco * C - [u1; r1; u2; r2]); %#ok<MINV>

ustar = subs(u, C, Csol);

% q = [subs(u, x, 0) == u1; subs(du, x, 0) == r1; subs(u, x, L) == u2; subs(du, x, L) == r2];
% sol = solve(q, C);
% Csol = [sol.C1, sol.C2, sol.C3, sol.C4];
% 
% ustar = subs(u, C, Csol);
% dustar = subs(du, C, Csol);
% 
% interps = equationsToMatrix(ustar, [u1; r1; u2; r2]);


% dp = int(int(int(w)));
% p = int(dp);