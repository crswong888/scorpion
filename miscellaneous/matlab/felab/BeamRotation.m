clear all %#ok<CLALL>
format longeng
fprintf('\n')

%// nodal coordinates
node = [100, 150, -300; -100, -150, 300];

%// direction vector
x = zeros(3,1);
for i = 1:3
    x(i) = node(2,i) - node(1,i); 
end

%// compute the length of the beam
L = norm(x);

%// x unit normal
nx = x / L;

%// y unit normal (assuming same rotation about z as x)
ny = [-nx(2), nx(1), 0];

%// z unit normal
nz = cross(nx, ny);

%// check orthogonal requirements (rounded to 16 significant figures)
isxyortho = round(dot(nx, ny), 16) == 0;
isxzortho = round(dot(nx, nz), 16) == 0;
isyzortho = round(dot(ny, nz), 16) == 0;