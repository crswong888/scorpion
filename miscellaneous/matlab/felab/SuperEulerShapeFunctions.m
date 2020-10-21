clear all %#ok<CLALL>
format longeng
fprintf('\n')

syms xi J
C = sym('C', [4 1]);

v = C(1) * xi^3 / 6 + C(2) * xi^2 / 2 + C(3) * xi + C(4);
dv = 1 / J * (C(1) * xi^2 / 2 + C(2) * xi + C(3));

q = [subs(v, xi, -1); subs(dv, xi, -1); subs(v, xi, 1); subs(dv, xi, 1)];

coefficients = equationsToMatrix(v, C);

straints = equationsToMatrix(q, C);
invstraints = inv(straints);

H = simplify(coefficients * invstraints); %#ok<MINV>