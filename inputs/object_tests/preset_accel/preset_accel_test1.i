# PresetAccel test Case 1: a fixed-fixed beam with accel BC
# applied equally at both ends. This model is undamped. The mass
# is uniformly distributed along its length.

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 20
  xmin = 0
  xmax = 500.0000
[]

[MeshModifiers]
  [./mid_point]
    type = AddExtraNodeset
    coord = 250.0000
    new_boundary = mid_point
  [../]
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
    # Identify variables
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'

    # dynamic simulation using consistent mass/inertia matrix
    dynamic_consistent_inertia = true
    density = 'density'

    # Identify auxillary variables
    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'

    # Geometry parameters
    area = 32.3336
    Iy = 568.6904
    Iz = 568.6904
    y_orientation = '0.0 1.0 0.0'

    # Newmark constant average acceleration parameters
    beta = 0.25
    gamma = 0.5
  [../]
[]

[Functions]
  [./ground_acceleration]
    type = ParsedFunction
    value = 'if(t<0.05, -(200*pi)^2*sin(200*pi*t), 0*t)'
  [../]
[]

[BCs]
  [./fixx]
    type = PresetBC
    variable = disp_x
    boundary = 'left right'
    value = 0.0
  [../]
  [./fixz]
    type = PresetBC
    variable = disp_z
    boundary = 'left right'
    value = 0.0
  [../]
  [fixrx]
    type = PresetBC
    variable = rot_x
    boundary = 'left right'
    value = 0.0
  [../]
  [fixry]
    type = PresetBC
    variable = rot_y
    boundary = 'left right'
    value = 0.0
  [../]
  [fixrz]
    type = PresetBC
    variable = rot_z
    boundary = 'left right'
    value = 0.0
    enable = true #fixed support = true
  [../]

  [./induce_acceleration]
    type = PresetAcceleration
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    boundary = 'left right'
    function = ground_acceleration
    beta = 0.25
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 117211
    poissons_ratio = 0.355
    shear_coefficient = 0.5397
  [../]
  [./stress]
    type = ComputeBeamResultants
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
  dt = 1.0E-4
  end_time = 0.1
  line_search = none
[]

[Postprocessors]
  [./disp_support]
    type = NodalMaxValue
    variable = disp_y
    boundary = left
  [../]
  [./vel_support]
    type = NodalMaxValue
    variable = vel_y
    boundary = left
  [../]
  [./accel_support]
    type = NodalMaxValue
    variable = accel_y
    boundary = left
  [../]
  [./disp_mid]
    type = NodalMaxValue
    variable = disp_y
    boundary = mid_point
  [../]
  [./relative_disp_mid]
    type = DifferencePostprocessor
    value1 = disp_mid
    value2 = disp_support
  [../]
  [./vel_mid]
    type = NodalMaxValue
    variable = vel_y
    boundary = mid_point
  [../]
  [./relative_vel_mid]
    type = DifferencePostprocessor
    value1 = vel_mid
    value2 = vel_support
  [../]
  [./accel_mid]
    type = NodalMaxValue
    variable = accel_y
    boundary = mid_point
  [../]
[]

[Outputs]
  file_base = outputs/preset_accel_test1_out
  exodus = true
  csv = true
  perf_graph = true
[]
