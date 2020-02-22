[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  rotations = 'rot_x rot_y rot_z'
[]

[Mesh]
  type = FileMesh
  file = case2_line.e
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
    #eta = 19.2355
    #zeta = 2.3287e-5
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
  [./initial_accel]
    type = PostprocessorIC
    variable = accel_y
    postprocessor = initial_accel_value
    boundary = 'support_a support_b support_c support_d'
  [../]
[]

[BCs]
  [./fixx]
    type = DirichletBC
    variable = disp_x
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
  [../]
  [./fixz]
    type = DirichletBC
    variable = disp_z
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
  [../]
  [./fixrx]
    type = DirichletBC
    variable = rot_x
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
  [../]
  [./fixry]
    type = DirichletBC
    variable = rot_y
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
  [../]

  [./induce_acceleration]
    type = PresetAcceleration
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    boundary = 'support_a support_b support_c support_d'
    function = adj_accel_func
    beta = 0.25
  [../]

  [./PresetLSBLCAcceleration]
    [./induce_LSBLC_acceleration]
      csv_file = 'accel_20hz.csv'
      accel_name = accel_20hz
      time_name = time
      start_time = 0.0
      end_time = 0.4
      order = 9 # becomes unstable after
      gamma = 0.5
      beta = 0.25
    [../]
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
  nl_rel_tol = 1e-06
  nl_abs_tol = 1e-08
  start_time = 0.0
  end_time = 1e-03
  dt = 1.0e-03
  timestep_tolerance = 1e-06
  line_search = none
  petsc_options = '-ksp_snes_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'
[]

[Postprocessors]
  [./disp_support]
    type = NodalMaxValue
    variable = disp_y
    boundary = support_a
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./vel_support]
    type = NodalMaxValue
    variable = vel_y
    boundary = support_a
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./accel_support]
    type = NodalMaxValue
    variable = accel_y
    boundary = support_a
    execute_on = 'INITIAL TIMESTEP_END'
  [../]

  [./initial_accel_value]
    type = VectorPostprocessorComponent
    index = 0
    vectorpostprocessor = BL_adjustments
    vector_name = adjusted_acceleration
    execute_on = INITIAL
    force_preic = true
  [../]
[]

[Outputs]
  exodus = true
  perf_graph = true
  [./postprocs]
    type = CSV
    execute_vector_postprocessors_on = NONE
  [../]
  [./BL_adjustments]
    type = CSV
    file_base = 20hz
    show = BL_adjustments
    time_column = false
    execute_on = INITIAL
    execute_postprocessors_on = NONE
  [../]
[]
