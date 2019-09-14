clear all

transverse = [0 1 0];

p = [-2 -3 4];

y_bar = [0 0 0];

y = transverse * transpose(p - y_bar);

disp_x = 0.0250;
disp_y = sqrt(y * y - disp_x * disp_x);

theta = acos(disp_x / y);

tan_0 = -y * cos(theta);

tan_1 = y * sin(theta);

surface_norm = zeros(3,1);
surface_norm(1,1) = tan_0 / sqrt(tan_0 * tan_0 + tan_1 * tan_1);
surface_norm(2,1) = tan_1 / sqrt(tan_0 * tan_0 + tan_1 * tan_1);
