[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  rotations = 'rot_x rot_y rot_z'
[]

[Mesh]
  type = FileMesh
  file = 3story_frame.e
  allow_renumbering = false
[]

[Functions]
  [ground_accel]
    type = PiecewiseLinear
    data_file = nominal_accel.csv
    format = columns
  []
[]

[Modules/TensorMechanics/LineElementMaster]
  add_variables = true
  velocities = 'vel_x vel_y vel_z'
  accelerations = 'accel_x accel_y accel_z'
  rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
  rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'

  dynamic_consistent_inertia = true
  beta = 0.25
  gamma = 0.5

  [L1_columns]
    block = L1_columns
    density = 2.399e-03 # N*s*s/cm/cm/cm/cm
    area = 364.5        # cm*cm
    Iy = 260600         # cm*cm*cm*cm
    Iz = 260600         # cm*cm*cm*cm
    y_orientation = '1 0 0'
  []
  [L1_beam]
    block = L1_beam
    density = 2.399e-03 # N*s*s/cm/cm/cm/cm
    area = 364.5        # cm*cm
    Iy = 260600         # cm*cm*cm*cm
    Iz = 260600         # cm*cm*cm*cm
    y_orientation = '0 1 0'
  []
  [L2_columns]
    block = L2_columns
    density = 2.363e-03 # N*s*s/cm/cm/cm/cm
    area = 308.4        # cm*cm
    Iy = 215200         # cm*cm*cm*cm
    Iz = 215200         # cm*cm*cm*cm
    y_orientation = '1 0 0'
  []
  [L2_beam]
    block = L2_beam
    density = 2.363e-03 # N*s*s/cm/cm/cm/cm
    area = 308.4        # cm*cm
    Iy = 215200         # cm*cm*cm*cm
    Iz = 215200         # cm*cm*cm*cm
    y_orientation = '0 1 0'
  []
  [L3_columns]
    block = L3_columns
    density = 2.341e-03 # N*s*s/cm/cm/cm/cm
    area = 249.0        # cm*cm
    Iy = 167300         # cm*cm*cm*cm
    Iz = 167300         # cm*cm*cm*cm
    y_orientation = '1 0 0'
  []
  [L3_beam]
    block = L3_beam
    density = 2.341e-03 # N*s*s/cm/cm/cm/cm
    area = 249.0        # cm*cm
    Iy = 167300         # cm*cm*cm*cm
    Iz = 167300         # cm*cm*cm*cm
    y_orientation = '0 1 0'
  []
[]

[Materials]
  [elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 20e06
    poissons_ratio = 0.3
    shear_coefficient = 0.8
  []
  [stress]
    type = ComputeBeamResultants
  []
[]

[BCs]
  [fixy]
    type = DirichletBC
    variable = disp_y
    boundary = base
    value = 0.0
  []
  [fixz]
    type = DirichletBC
    variable = disp_z
    boundary = base
    value = 0.0
  []
  [fixrx]
    type = DirichletBC
    variable = rot_x
    boundary = base
    value = 0.0
  []
  [fixry]
    type = DirichletBC
    variable = rot_y
    boundary = base
    value = 0.0
  []
  [fixrz]
    type = DirichletBC
    variable = rot_z
    boundary = base
    value = 0.0
  []
  [induce_accel]
    type = PresetAcceleration
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    function = ground_accel
    boundary = base
    beta = 0.25
  []
[]

[Preconditioning]
  [smp]
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
  start_time = -5
  end_time = 5
  dt = 0.01
  timestep_tolerance = 1e-08 # this is needed so that solver doesn't fail on very last time step
  petsc_options = '-ksp_snes_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'
[]

[Postprocessors]
  [ground_displacement]
    type = PointValue
    variable = disp_x
    point = '0.0 0.0 0.0'
    execute_on = 'INITIAL TIMESTEP_END'
    force_preic = true
  []
  [roof_displacement]
    type = PointValue
    variable = disp_x
    point = '700.0 700.0 0.0'
    execute_on = 'INITIAL TIMESTEP_END'
    force_preic = true
  []
  [relative_displacement]
    type = DifferencePostprocessor
    value1 = ground_displacement
    value2 = roof_displacement
    execute_on = 'INITIAL TIMESTEP_END'
    force_preic = true
  []
[]

[Outputs]
  exodus = true
  csv = true
  perf_graph = true
[]
