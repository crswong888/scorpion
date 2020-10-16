clear all %#ok<CLALL>
format longeng
fprintf('\n')

%// nodal coordinates
node = [1.4, 2, -1.4; -1.4, -2, 1.4];

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

%// check orthogonal requirements
isxyortho = dot(nx, ny) == 0;
isxzortho = dot(nx, nz) == 0;
isyzortho = dot(ny, nz) == 0;