clear all %#ok<CLALL>
format rat
fprintf('\n')

%//
accel_fit_order = 10;

%//
syms T

%//
num_coeffs = accel_fit_order + 1;
KA = sym(zeros(num_coeffs, num_coeffs));
for k = 1:num_coeffs
    for j = 1:num_coeffs
        KA(k,j) = (j * j + j) * T^(k + j - 1) / (k + j - 1) ;
    end
end

%/
invKA = simplify(inv(KA));

%%% devel

% a = sym('a%d%d', [1, num_coeffs]);
% b = sym('b%d%d', [num_coeffs, num_coeffs]);
% 
% KA = sym(zeros(num_coeffs, num_coeffs));
% for k = 1:num_coeffs
%     for j = 1:num_coeffs
%         KA(k,j) = a(j) / b(k,j) ;
%     end
% end
% 
% %/
% invKA = simplify(inv(KA));

% %%% devel
% invKA = simplify(subs(invKA, T, 1));
% 
% horizontal_diff = zeros(accel_fit_order, num_coeffs);
% vertical_diff = zeros(num_coeffs, accel_fit_order);
% for k = 1:accel_fit_order
%     horizontal_diff(k,:) = invKA((k + 1),:) - invKA(k,:);
%     vertical_diff(:,k) = invKA(:,(k + 1)) - invKA(:,k);
% end
% 
% syms a b c d e f k j
% % seriesfunc = (a * k + b * j + c) / (d * k + e * j + f);
% % 
% % conds = [subs(seriesfunc, [k, j], [1, 1]) == 9 / 2;
% %          subs(seriesfunc, [k, j], [2, 1]) == -6;
% %          subs(seriesfunc, [k, j], [3, 1]) == 5 / 2;
% %          subs(seriesfunc, [k, j], [1, 2]) == -18;
% %          subs(seriesfunc, [k, j], [1, 3]) == 15;
% %          subs(seriesfunc, [k, j], [2, 2]) == 32];
% %      
% % sol = solve(conds, [a; b; c; d; e; f]);
% 
% seriesfunc = a * k / (b * j);
% 
% conds = [subs(seriesfunc, [k, j], [1, 1]) == 9 / 2;
%          subs(seriesfunc, [k, j], [2, 1]) == -6];
%      
% sol = solve(conds, [a; b]);