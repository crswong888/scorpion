[Mesh]
  type = AnnularMesh
  nt = 32
  rmax = 6.35
  rmin = 5.48
  growth_r = 1
  nr = 3
  #parallel_type = DISTRIBUTED
  partitioner = centroid
  centroid_partitioner_direction = z
[]

[MeshModifiers]
  [./make3D]
    type = MeshExtruder
    extrusion_vector = '0 0 1676'
    num_layers = 1676
    bottom_sideset = 'support_a'
    top_sideset = 'support_d'
    existing_subdomains = '0'
    layers = '260 261 521 522 782 783 1043 1044 1359 1360'
    new_ids = '261 262 522 523 783 784 1044 1045 1360 1361'
  [../]
  [./accelerometer_a]
    type = SideSetsBetweenSubdomains
    master_block = 261
    paired_block = 262
    new_boundary = accelerometer_a
    depends_on = make3D
  [../]
  [./support_b]
    type = SideSetsBetweenSubdomains
    master_block = 522
    paired_block = 523
    new_boundary = support_b
    depends_on = make3D
  [../]
  [./accelerometer_b]
    type = SideSetsBetweenSubdomains
    master_block = 783
    paired_block = 784
    new_boundary = accelerometer_b
    depends_on = make3D
  [../]
  [./support_c]
    type = SideSetsBetweenSubdomains
    master_block = 1044
    paired_block = 1045
    new_boundary = support_c
    depends_on = make3D
  [../]
  [./accelerometer_c]
    type = SideSetsBetweenSubdomains
    master_block = 1360
    paired_block = 1361
    new_boundary = accelerometer_c
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
    zeta = 1.3986E-5
  [../]
  [./inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.25
    gamma = 0.5
    eta = 40.9536
  [../]
  [./inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.25
    gamma = 0.5
    eta = 40.9536
  [../]
  [./inertia_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    beta = 0.25
    gamma = 0.5
    eta = 40.9536
  [../]
  [./gravity]
    type = Gravity
    variable = disp_y
    value = -9810
    enable = false # gravity=true
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

[Functions]
  [./ground_displacement]
    type = ParsedFunction
    value = 'if(t<0.1, 5.1*sin(pi*t/0.025), 0*t)'
  [../]
[]

[BCs]
  [./fixy]
    type = PresetBC
    variable = disp_y
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
  [../]
  [./fixz]
    type = PresetBC
    variable = disp_z
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
  [../]
  [./induce_displacement]
    type = FunctionPresetBC
    variable = disp_x
    boundary = 'support_a support_b support_c support_d'
    function = ground_displacement
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 117211
    poissons_ratio = 0.355
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
    prop_values = 8.94E-9
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
  dt = 2.5E-4
  end_time = 0.4
[]

[Postprocessors]
  [./disp_a]
    type = NodalMaxValue
    variable = disp_y
    boundary = accelerometer_a
  [../]
  [./vel_a]
    type = NodalMaxValue
    variable = vel_y
    boundary = accelerometer_a
  [../]
  [./accel_a]
    type = NodalMaxValue
    variable = accel_y
    boundary = accelerometer_a
  [../]
  [./disp_b]
    type = NodalMaxValue
    variable = disp_y
    boundary = accelerometer_b
  [../]
  [./vel_b]
    type = NodalMaxValue
    variable = vel_y
    boundary = accelerometer_b
  [../]
  [./accel_b]
    type = NodalMaxValue
    variable = accel_y
    boundary = accelerometer_b
  [../]
  [./disp_c]
    type = NodalMaxValue
    variable = disp_y
    boundary = accelerometer_c
  [../]
  [./vel_c]
    type = NodalMaxValue
    variable = vel_y
    boundary = accelerometer_c
  [../]
  [./accel_c]
    type = NodalMaxValue
    variable = accel_y
    boundary = accelerometer_c
  [../]
  [./accel_support]
    type = NodalMaxValue
    variable = accel_y
    boundary = support_a
  [../]
  [./ground_displacement]
    type = FunctionValuePostprocessor
    function = ground_displacement
  [../]
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
