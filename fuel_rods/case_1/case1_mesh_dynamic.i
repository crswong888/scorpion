# Case 1: Cladding only length of 10 pellets (128.8-mm)
# Tests Case 1 - Dynamic impulse loading using a 3D annular mesh

# Material properties are of unirradiated, in-tact Zr-4 cladding.

# With (eta) = 996.7809 and (zeta) = 4.7603E-7, damping is 2.2% to 3% from 1st to 3rd mode 
# frequency of 3133.5193-Hz to 16926.5999-Hz, respectively. 

# These Rayleigh parameters are valid only for a fixed-fixed scenario

# Fastest on 3 processors and 3 threads

[Mesh]
  type = AnnularMesh
  nt = 32
  rmax = 5.36
  rmin = 4.76
  growth_r = 1
  nr = 4
  #parallel_type = DISTRIBUTED
  partitioner = centroid
  centroid_partitioner_direction = z
[]

[MeshModifiers]
  [./make3D]
    type = MeshExtruder
    extrusion_vector = '0 0 128.8'
    num_layers = 64
    bottom_sideset = 'left'
    top_sideset = 'right'
    existing_subdomains = '0'
    layers = '31 32'
    new_ids = '32 33'
  [../]
  [./mid_point]
    type = SideSetsBetweenSubdomains
    master_block = 32
    paired_block = 33
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

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
[]

[AuxVariables]
  [./vel_x]
  [../]
  [./accel_x]
  [../]
  [./vel_y]
  [../]
  [./accel_y]
  [../]
  [./vel_z]
  [../]
  [./accel_z]
  [../]
[]

[Kernels]
  [./DynamicTensorMechanics]
    displacements = 'disp_x disp_y disp_z'
    zeta = 4.7603E-7
  [../]
  [./inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.25
    gamma = 0.5
    eta = 0.0
  [../]
  [./inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.25
    gamma = 0.5
    eta = 996.7809
  [../]
  [./inertia_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    beta = 0.25
    gamma = 0.5
    eta = 996.7809
  [../]
[]

[AuxKernels]
  [./accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.5
  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.25
  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.5
  [../]
  [./accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    beta = 0.25
  [../]
  [./vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    gamma = 0.5
  [../]
[]

[Kernels]
  [./gravity]
    type = Gravity
    variable = disp_y
    value = -9810
    enable = false # gravity=true
  [../]
[]

[NodalKernels]
  [./force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = mid_point
    enable = true # apply_force=true
  [../]
[]

[Functions]
  [./load]
    type = ParsedFunction
    value = 'if(t<0.002, -0.15625*sin(pi*t/0.002), 0*t)' # 25.0N/160node=0.15625N/node
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
    boundary = right
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
  [./strain]
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y disp_z'
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    #outputs = exodus
    #output_properties = stress
    store_old_stress = true
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
  solve_type = NEWTON
  start_time = 0.0
  dt = 1.0E-5
  end_time = 0.005
[]

[Postprocessors]
  [./disp_y]
    type = NodalMaxValue
    variable = disp_y
    boundary = mid_point
  [../]
  [./vel_y]
    type = NodalMaxValue
    variable = vel_y
    boundary = mid_point
  [../]
  [./accel_y]
    type = NodalMaxValue
    variable = accel_y
    boundary = mid_point
  [../]
  [./pressure]
    type = FunctionValuePostprocessor
    function = load
  [../]
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
