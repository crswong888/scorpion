# THIS MODEL IS CURRENTLY UNDER CONSTRUCTION

# This is an input file for a 1D line mesh model of a half-length surrogate Cu nuclear fuel rod with torsional spring supports

# The ExplicitEuler TimeIntegration scheme is slightly faster than ImplicitEuler (default)

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  rotations = 'rot_x rot_y rot_z'
[]

[Mesh]
  type = FileMesh
  file = ../case2_line.e
  partitioner = parmetis
  allow_renumbering = false
[]

[Modules/TensorMechanics/LineElementMaster]
  [./fuel_rod]
    add_variables = true
    block = fuel_rod
    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'

    # Geometry parameters
    area = 32.3336
    Iy = 568.6904
    Iz = 568.6904
    y_orientation = '0.0 1.0 0.0'

    # dynamic simulation using consistent mass/inertia matrix
    dynamic_consistent_inertia = true
    density = density
    beta = 0.25
    gamma = 0.5
    eta = 19.2355
    zeta = 2.3287e-5
  [../]
[]

[Functions]
  [./ground_velocity]
    type = PiecewiseLinear
    data_file = 'vel_20hz.csv'
    format = columns
  [../]
  [./initial_vel]
    type = ConstantFunction
    value = -640.8849
  [../]
[]

[Materials]
  [./fuel_rod_elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 117211
    poissons_ratio = 0.355
    shear_coefficient = 0.5397
    block = fuel_rod
  [../]
  [./stress]
    type = ComputeBeamResultants
    outputs = exodus
    output_properties = 'forces moments'
    block = fuel_rod
  [../]
  [./rod_density]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 8.94e-9
    block = fuel_rod
  [../]
[]

[ICs]
  #probably need an accel IC foo im guessing?
  [./initial_vel]
    type = FunctionIC
    variable = vel_y
    function = initial_vel
    boundary = 'support_a support_b support_c support_d'
    enable = false
  [../]
[]

[BCs]
  [./fixx]
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
  [./fixrx]
    type = PresetBC
    variable = rot_x
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
  [../]
  [./fixry]
    type = PresetBC
    variable = rot_y
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
  [../]

  [./induce_velocity]
    type = PresetVelocity
    variable = disp_y
    boundary = 'support_a support_b support_c support_d'
    function = ground_velocity
  [../]

  [./fixy]
    type = PresetBC
    variable = disp_y
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
    enable = false
  [../]
[]

[Controls]
  [./stop_displacement]
    type = TimePeriod
    enable_objects = '*/fixy'
    start_time = 0.1
    end_time = 0.4
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -sub_pc_factor_shift_type'
    petsc_options_value = ' gmres     asm      lu           NONZERO'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  scheme = explicit-euler
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8
  start_time = 0.0
  end_time = 0.4
  dt = 1.0E-4
  timestep_tolerance = 1e-6
  line_search = none
  petsc_options = '-ksp_snes_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'
[]

[Postprocessors]
  [./disp_a]
    type = NodalMaxValue
    variable = disp_y
    boundary = accelerometer_a
  [../]
  [./relative_disp_a]
    type = DifferencePostprocessor
    value1 = disp_a
    value2 = disp_support
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
  [./relative_disp_b]
    type = DifferencePostprocessor
    value1 = disp_b
    value2 = disp_support
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
  [./relative_disp_c]
    type = DifferencePostprocessor
    value1 = disp_c
    value2 = disp_support
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

  [./ground_velocity]
    type = FunctionValuePostprocessor
    function = ground_velocity
  [../]

[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
