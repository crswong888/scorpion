# THIS MODEL IS CURRENTLY UNDER CONSTRUCTION

# Works best 3 processors, 3 threads, linear partitioner type
# Centroid_z similar but a little longer solve time

# The ExplicitEuler TimeIntegration scheme is slightly faster than ImplicitEuler (default)

# Using FunctionPresetBC to induce shake-table motion at supports
# When using a Dirichlet BC, it creates a lot of noise with the acceleration
# MOOSE has also reported this issue

# MOOSE reccomends to use PresetDisplacement or PresetAcceleration
# At this point, I am having issues when using these BC types

[Mesh]
  type = AnnularMesh
  nt = 32
  rmax = 6.35
  rmin = 5.48
  growth_r = 1
  nr = 3
  partitioner = linear
  #partitioner = centroid
  #centroid_partitioner_direction = z
[]

[MeshModifiers]
  [./make3D]
    type = MeshExtruder
    extrusion_vector = '0 0 1676'
    num_layers = 838
    bottom_sideset = 'support_a'
    top_sideset = 'support_d'
    existing_subdomains = '0'
    layers = '129 260 261 390 521 522 679 680'
    new_ids = '130 261 262 391 522 523 680 681'
  [../]
  [./rename_blocks]
    type = RenameBlock
    old_block_id = '130 391'
    new_block_name = 'accelerometer_a accelerometer_b'
  [../]
  [./support_b]
    type = SideSetsBetweenSubdomains
    master_block = 261
    paired_block = 262
    new_boundary = support_b
    depends_on = make3D
  [../]
  [./support_c]
    type = SideSetsBetweenSubdomains
    master_block = 522
    paired_block = 523
    new_boundary = support_c
    depends_on = make3D
  [../]
  [./accelerometer_c]
    type = SideSetsBetweenSubdomains
    master_block = 680
    paired_block = 681
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
  [./no_disp_x]
    type = PresetBC
    variable = disp_x
    boundary = 'rmin rmax'
    value = 0.0
  [../]
  
  [./fixy]
    type = PresetBC
    variable = disp_x
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
    variable = disp_y
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
    store_stress_old = true
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
  scheme = explicit-euler
  start_time = 0.0
  dt = 1.0E-3
  end_time = 0.4
  line_search = none
[]

[Postprocessors]
  [./disp_a]
    type = ElementExtremeValue
    variable = disp_y
    block = 'accelerometer_a'
  [../]
  [./vel_a]
    type = ElementExtremeValue
    variable = vel_y
    block = 'accelerometer_a'
  [../]
  [./accel_a]
    type = ElementExtremeValue
    variable = accel_y
    block = 'accelerometer_a'
  [../]
  [./disp_b]
    type = ElementExtremeValue
    variable = disp_y
    block = 'accelerometer_b'
  [../]
  [./vel_b]
    type = ElementExtremeValue
    variable = vel_y
    block = 'accelerometer_b'
  [../]
  [./accel_b]
    type = ElementExtremeValue
    variable = accel_y
    block = 'accelerometer_b'
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
  [./disp_support]
    type = NodalMaxValue
    variable = disp_y
    boundary = support_a
  [../]
  [./vel_support]
    type = NodalMaxValue
    variable = vel_y
    boundary = support_a
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
