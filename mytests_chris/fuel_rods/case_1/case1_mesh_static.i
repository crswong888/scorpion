# Case 1: Cladding only length of 10 pellets (128.8-mm)
# Tests Case 1 - Static axial loading using a 3D annular mesh

# Material properties are of unirradiated, in-tact Zr-4 cladding.

# Fastest on 3 processors and 3 threads

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = AnnularMesh
  nt = 32
  rmax = 5.36
  rmin = 4.76
  growth_r = 1
  nr = 3
  #parallel_type = DISTRIBUTED
  partitioner = centroid
  centroid_partitioner_direction = z
[]

[MeshModifiers]
  [./make3D]
    type = MeshExtruder
    extrusion_vector = '0 0 128.8'
    num_layers = 30
    bottom_sideset = 'left'
    top_sideset = 'right'
    existing_subdomains = '0'
    layers = '14 15'
    new_ids = '15 16'
  [../]
  [./mid_point]
    type = SideSetsBetweenSubdomains
    master_block = 15
    paired_block = 16
    new_boundary = mid_point
    depends_on = make3D
  [../]
  [./fix_nodes_left]
    type = BoundingBoxNodeSet
    new_boundary = 'left_center'
    top_right = '5.36 0.01 0'
    bottom_left = '-5.36 0 0'
    depends_on = make3D
  [../]
  [./fix_nodes_right]
    type = BoundingBoxNodeSet
    new_boundary = 'right_center'
    top_right = '5.36 0.01 128.8'
    bottom_left = '-5.36 0 128.8'
    depends_on = make3D
  [../]
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = True
  [../]
[]

[Kernels]
  [./gravity]
    type = Gravity
    variable = disp_y
    value = -9810
    enable = true # gravity=true
  [../]
[]

[NodalKernels]
  [./force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = mid_point
    enable = false # apply_force=true
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = -19.5313 # total_load/no_nodes=2500N/128node=19.5313N/node
  [../]
[]

[BCs]
  [./no_disp_x]
    type = PresetBC
    variable = disp_x
    boundary = 'rmin rmax'
    value = 0.0
  [../]


  # LEFT BOUNDARY CONDITIONS

  [./fixy1_center]
    type = PresetBC
    variable = 'disp_y'
    boundary = left_center
    value = 0.0
  [../]
  [./fixz1_center]
    type = PresetBC
    variable = 'disp_z'
    boundary = left_center
    value = 0.0
  [../]

  [./fixx1]
    type = PresetBC
    variable = disp_x
    boundary = left
    value = 0.0
  [../]

  [./fixy1]
    type = PresetBC
    variable = disp_y
    boundary = left
    value = 0.0
    enable = true # pin=false, fix=true
  [../]
  [./fixz1]
    type = PresetBC
    variable = disp_z
    boundary = left
    value = 0.0
    enable = true # pin=false, fix=true
  [../]


  # RIGHT BOUNDARY CONDITIONS

  [./fixy2_center]
    type = PresetBC
    variable = 'disp_y'
    boundary = right_center
    value = 0.0
  [../]

  [./fixx2]
    type = PresetBC
    variable = disp_x
    boundary = 'right right_center'
    value = 0.0
  [../]

  [./fixy2]
    type = PresetBC
    variable = disp_y
    boundary = right
    value = 0.0
    enable = true # roller=false, fix=true
  [../]
  [./fixz2]
    type = PresetBC
    variable = disp_z
    boundary = right
    value = 0.0
    enable = true # roller=false, fix=true
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 9.93E4
    poissons_ratio = 0.37
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    #outputs = exodus
    #output_properties = stress
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 6.0E-9 # Approximate density of Zr-4
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_atol -snes_rtol -snes_max_it -ksp_atol -ksp_rtol -sub_pc_factor_shift_type'
    petsc_options_value = 'gmres asm lu 1E-8 1E-8 25 1E-8 1E-8 NONZERO'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = Newton
  scheme = explicit-euler
  num_steps = 1
[]

[Postprocessors]
  [./disp_y]
    type = NodalMaxValue
    variable = disp_y
    boundary = mid_point
  [../]
  [./force_y]
    type = FunctionValuePostprocessor
    function = load
  [../]
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
