%%% compare this to the result for 'I' (rhs of normal equation) in twenty sines input file in BLC

clear all %#ok<CLALL>
format longeng
fprintf('\n')

syms t J pi

order = 9;
Jsub = 0.8;

%// compare solA to a fit on nominal acceleration
intvalA = sym(zeros(order + 1, 1));
solA = zeros(order + 1, 1);
for k = 1:(order + 1)
    f(t) = -250 * pi * pi * J * J * t^(k - 1) * sin(50 * pi * (t * J));
    intvalA(k) = simplify(int(f, 0, 1));

    solA(k) = double(subs(intvalA(k), J, Jsub));
end

%// compare solB to a fit on nominal velocity
intvalB = sym(zeros(order + 1, 1));
solB = zeros(order + 1, 1);
for k = 1:(order + 1)
    f(t) = J * t^(k) * (5 * pi * cos(50 * pi * (t * J)) - 5 * pi);
    intvalB(k) = simplify(int(f, 0, 1));

    solB(k) = double(subs(intvalB(k), J, Jsub));
end

%// compare solC to a fit on nominal displacement
order = 7;
intvalC = sym(zeros(order + 1, 1));
solC = zeros(order + 1, 1);
for k = 1:(order + 1)
    f(t) = t^(k + 1) * (0.1 * sin(50 * pi * (t * J)) - 5 * pi * (t * J));
    intvalC(k) = simplify(int(f, 0, 1));

    solC(k) = double(subs(intvalC(k), J, Jsub));
end
