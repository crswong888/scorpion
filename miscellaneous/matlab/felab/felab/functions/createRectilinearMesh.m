function [nodes, elements] = createRectilinearMesh(eletype, varargin)
    %%% TODO: make it possible to specify spatial position of created mesh (an origin param)

    %// inputs for the element type and its dimensions
    params = inputParser; % create instance to access the inputParser class
    addRequired(params, 'eletype', @(x) any(validatestring(x, {'QUAD4', 'HEX8'})));
    validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0); % valid input type
    addParameter(params, 'Lx', [], validScalarPosNum);
    addParameter(params, 'Ly', [], validScalarPosNum);
    addParameter(params, 'Lz', [], validScalarPosNum);
    addParameter(params, 'Nx', [], validScalarPosNum);
    addParameter(params, 'Ny', [], validScalarPosNum);
    addParameter(params, 'Nz', [], validScalarPosNum);
    
    %// parse inputs into class instance - optional props should be input in expected appendix order
    params.KeepUnmatched = true; % unmatched inputs, e.g., mat props, will be appended to elements table
    params.PartialMatching = false; % make sure were not accidentally pairing unmatches to known params
    parse(params, eletype, varargin{:}); % parse the inputs into the class instance
    
    %%%%%%%%%%%%%
    %%% QUAD4 %%%
    %%%%%%%%%%%%%

    if (strcmp(params.Results.eletype, 'QUAD4'))
        %// validate existance of the required input params
        validateRequiredParams(params, 'Lx', 'Ly', 'Nx', 'Ny')
        %/ copy values to simpler pointers
        Lx = params.Results.Lx; 
        Ly = params.Results.Ly; 
        Nx = params.Results.Nx; 
        Ny = params.Results.Ny;
        
        %// compute total number of nodes and number of elements
        num_nodes = (Nx + 1) * (Ny + 1); 
        num_elems = Nx * Ny;

        %// compute x and y dimensions of the elements
        dx = Lx / Nx; 
        dy = Ly / Ny;

        %// generate node coordinate table (ID, x, y)
        ID = transpose(1:num_nodes); 
        x = zeros(num_nodes, 1); 
        y = x;
        for i = 1:num_nodes 
            row = ceil(i / (Nx + 1)); 
            col = i + (Nx + 1) * (1 - row);
            
            x(i) = (col - 1) * dx; 
            y(i) = (row - 1) * dy;
        end
        nodes = table(ID, x, y);

        %// generate element connectivity table in counter-clockwise fashion (ID, n1, n2, n3, n4)
        ID = transpose(1:num_elems); 
        n1 = zeros(num_elems, 1); 
        n2 = n1; n3 = n1; n4 = n1;
        for e = 1:num_elems
            row = ceil(e / Nx);
            
            n1(e) = e + row - 1; 
            n2(e) = n1(e) + 1;
            n3(e) = e + Nx + row + 1; 
            n4(e) = n3(e) - 1;
        end
        elements = table(ID, n1, n2, n3, n4);
     
    %%%%%%%%%%%%
    %%% HEX8 %%%
    %%%%%%%%%%%%    
    
    else
        %// validate existance of the required input params
        validateRequiredParams(params, 'Lx', 'Ly', 'Lz', 'Nx', 'Ny', 'Nz')
        %/ copy values to simpler pointers
        Lx = params.Results.Lx; 
        Ly = params.Results.Ly; 
        Lz = params.Results.Lz;
        Nx = params.Results.Nx; 
        Ny = params.Results.Ny; 
        Nz = params.Results.Nz;
        
        %// compute total number of nodes and number of elements
        num_nodes = (Nx + 1) * (Ny + 1) * (Nz + 1); 
        num_elems = Nx * Ny * Nz;
        %/ compute the number of nodes in one plane only
        num_in_plane = num_nodes / (Nz + 1);
        
        %// compute x, y, and z dimensions of the elements
        dx = Lx / Nx; 
        dy = Ly / Ny; 
        dz = Lz / Nz;
        
        %// generate node coordinate table (ID, x, y, z)
        ID = transpose(1:num_nodes); 
        x = zeros(num_nodes,1); 
        y = x; z = x;
        for i = 1:num_nodes 
            row = ceil(i / (Nx + 1)); 
            col = i + (Nx + 1) * (1 - row);
            ext = ceil(i / num_in_plane);
            
            x(i) = (col - 1) * dx; 
            y(i) = (row - 1) * dy; 
            z(i) = (ext - 1) * dz;
        end
        nodes = table(ID, x, y, z);
        
        %// generate element connectivity table in counter-clockwise fashion (ID, n1, n2, ..., n8)
        ID = transpose(1:num_elems); 
        n1 = zeros(num_elems, 1); 
        n2 = n1; n3 = n1; n4 = n1; n5 = n1; n6 = n1; n7 = n1; n8 = n1;
        for e = 1:num_elems
            row = ceil(e / Nx);
            
            n1(e) = e + row - 1; n2(e) = n1(e) + 1;
            n3(e) = e + Nx + row + 1; n4(e) = n3(e) - 1;
            n5(e) = n1(e) + num_in_plane; n6(e) = n2(e) + num_in_plane;
            n7(e) = n3(e) + num_in_plane; n8(e) = n4(e) + num_in_plane;
        end
        elements = table(ID, n1, n2, n3, n4, n5, n6, n7, n8);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% ELEMENT PROPERTIES %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % NOTE: properties appended to element table are optional and must be constant scalar values
    
    if (~isempty(params.Unmatched))
        %// supress warning about appending row values to individual table variables (columns)
        warning('off', 'MATLAB:table:RowsAddedExistingVars')
        
        %// write names of unmatched fields from input parser and their values to table format
        props = struct2table(params.Unmatched);
        for idx = 1:length(props{1,:})
            props{2:num_elems,idx} = props{1,idx}; % copy the value to all elements
        end
        
        %// append the additional input properties to the element table
        elements = cat(2, elements, props);
        
        %// turn the warning back on before returning
        warning('on', 'MATLAB:table:RowsAddedExistingVars')
    end
    
    % TODO: it would be better to create an element block system and assign material properties
end