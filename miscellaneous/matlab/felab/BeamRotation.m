clear all %#ok<CLALL>
format longeng
fprintf('\n')

%// nodal coordinates
node = [75, 100, -300; -75, -100, 300];

%// direction vector
x = zeros(1,3);
for i = 1:3
    x(i) = node(2,i) - node(1,i); 
end

%// compute the length of the beam
L = norm(x);

%// x unit normal
nx = x / L;

%// y unit normal (assuming same rotation about z as x)
ny = [-nx(2), nx(1), 0] / norm([-nx(2), nx(1), 0]);

%// z unit normal
nz = cross(nx, ny);

%// check orthogonal requirements (rounded to 12 significant figures)
isxyortho = round(dot(nx, ny), 12) == 0;
isxzortho = round(dot(nx, nz), 12) == 0;
isyzortho = round(dot(ny, nz), 12) == 0;

%%% note, if x is a pythagorean quadruplet and y is a triplet, `format rat` may come in handy
%%%
%%% also note that ny = cross(nx, -nz)