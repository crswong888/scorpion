# Case 1: Cladding only length of 10 pellets
# Tests Case 1 - Dynamic impulse loading using a 3D annular mesh

# Fastest on 3 processors and 3 threads

[Mesh]
  type = AnnularMesh
  nt = 32
  rmax = 5.36
  rmin = 4.76
  growth_r = 1.0
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
    bottom_sideset = 'bottom'
    top_sideset = 'top'
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
    zeta = 9.2412E-4
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
    eta = 0.1216
  [../]
  [./inertia_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    beta = 0.25
    gamma = 0.5
    eta = 0.0
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
    enable = false #gravity?
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
    value = 'if(t<0.2, -19.53125*sin(pi*t/0.2), 0*t)' #2500N/128node=19.53125N/node
  [../]
[]

[BCs]
  [./no_disp_x]
    type = PresetBC
    variable = disp_x
    boundary = 'rmin rmax'
    value = 0.0
  [../]
  [./fixx1]
    type = PresetBC
    variable = disp_x
    boundary = top
    value = 0.0
  [../]
  [./fixy1]
    type = PresetBC
    variable = disp_y
    boundary = top
    value = 0.0
  [../]
  [./fixz1]
    type = PresetBC
    variable = disp_z
    boundary = top
    value = 0.0
  [../]
  [./fixx2]
    type = PresetBC
    variable = disp_x
    boundary = bottom
    value = 0.0
  [../]
  [./fixy2]
    type = PresetBC
    variable = disp_y
    boundary = bottom
    value = 0.0
  [../]
  [./fixz2]
    type = PresetBC
    variable = disp_z
    boundary = bottom
    value = 0.0
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
    prop_values = 6.0E-9
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
  dt = 0.01
  end_time = 1.0
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
