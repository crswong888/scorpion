function [node_file, elem_file] = writeRectilinearMesh(Lx, Nx, Ly, Ny, type)
    
    %// generate file name directories and appendages
    base_name = cat(2, cd, '\', dbstack(1).name, '_files\', dbstack(1).name, '_');
    node_file = cat(2, base_name, 'nodes.csv');
    elem_file = cat(2, base_name, 'elements.csv');
    
    if (strcmp(type, 'QUAD4'))
        %// compute total number of nodes and number of elements
        num_nodes = (Nx + 1) * (Ny + 1); num_elems = Nx * Ny;

        %// compute z and y dimensions of the elements
        dx = Lx / Nx; dy = Ly / Ny;

        %// generate node coordinate table (ID, x, y) and write out the csv file
        ID = transpose(1:num_nodes); x = zeros(num_nodes,1); y = zeros(num_nodes,1);
        for i = 1:num_nodes 
            row = ceil(i / (Nx + 1)); col = i + (Nx + 1) * (1 - row);
            x(i) = (col - 1) * dx; 
            y(i) = (row - 1) * dy;
        end, writetable(table(ID, x, y), node_file)

        %// generate element connectivity table in counter-clockwise fashion (ID, n1, n2, n3, n4)
        ID = transpose(1:num_elems); n1 = zeros(num_elems,1); n2 = n1; n3 = n1; n4 = n1;
        for e = 1:num_elems
            row = ceil(e / Nx);
            n1(e) = e + row - 1;
            n2(e) = n1(e) + 1;
            n3(e) = e + Nx + row + 1;
            n4(e) = n3(e) - 1;
        end, writetable(table(ID, n1, n2, n3, n4), elem_file)
    end
    
    %// make sure file path reference exists in base directory
    evalin('base', ['addpath(''', dbstack(1).name, '_files'')'])

end