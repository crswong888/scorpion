clear all %#ok<CLALL>
format longeng
fprintf('\n')

%%% This won't work for abitrary time series, because the number of intervals needs to be even,
%%% unless you incorporate a 3/8 Simpson rule to compensate an odd number. Also, the standard
%%% formula is based on equal increment size over the whole domain, which is not always practical.
%%% There are methods to handle unequal increments (like the link below), but this would become
%%% difficult to merge with also compensating for odd intervals... so not exactly worth it.
%%% Furthermore, Simpson's rule is not only conditionally stable.

dx = 1e-04;
x = 0:dx:1;
N = length(x);
f = zeros(1, N);
for i = 1:N
    f(i) = -250 * 0.8 * 0.8 * pi * pi * x(i) * sin(50 * 0.8 * pi * x(i));
end

%// Simpson's rule
X1 = 0;
X2 = 0;
for i = 1:((N - 1) / 2)
    X1 = X1 + f(2 * i);
    X2 = X2 + f(2 * i + 1);
end
I1 = dx * (f(1) + 2 * X1 + 4 * X2 + f(N)) / 3;

%// trapezoidal rule for comparison
I2 = dx * (f(1) + 2 * sum(f(2:(N - 1))) + f(N)) / 2;

%// Simpson's rule w/ unequal divisions
%(https://www.researchgate.net/publication/265499536_Simpson's_13-rule_of_integration_for_unequal_divisions_of_integration_domain)
H1 = (x(3) - x(1)) * (3 * x(2) - 2 * x(1) - x(3)) / (x(2) - x(1));
X1 = H1 * f(1);
X2 = 0;
X3 = 0;
for i = 2:((N - 1) / 2)
end
