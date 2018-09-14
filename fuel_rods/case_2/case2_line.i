# THIS MODEL IS CURRENTLY UNDER CONSTRUCTION

# Works best 3 processors, 3 threads, default partitioner type

# The ExplicitEuler TimeIntegration scheme is slightly faster than ImplicitEuler (default)

# Using FunctionPresetBC to induce shake-table motion at supports
# When using a Dirichlet BC, it creates a lot of noise with the acceleration
# MOOSE has also reported this issue

# MOOSE reccomends to use PresetDisplacement or PresetAcceleration
# At this point, I am having issues when using these BC types

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1676
  xmin = 0
  xmax = 1676
  construct_node_list_from_side_list = false
[]

[MeshModifiers]
  [./support_a]
    type = AddExtraNodeset
    coord = 0
    new_boundary = support_a
  [../]
  [./accelerometer_a]
    type = AddExtraNodeset
    coord = 261
    new_boundary = accelerometer_a
  [../]
  [./support_b]
    type = AddExtraNodeset
    coord = 522
    new_boundary = support_b
    force_prepare = true
  [../]
  [./accelerometer_b]
    type = AddExtraNodeset
    coord = 783
    new_boundary = accelerometer_b
  [../]
  [./support_c]
    type = AddExtraNodeset
    coord = 1044
    new_boundary = support_c
  [../]
  [./accelerometer_c]
    type = AddExtraNodeset
    coord = 1360
    new_boundary = accelerometer_c
  [../]
  [./support_d]
    type = AddExtraNodeset
    coord = 1676
    new_boundary = support_d
  [../]
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
  [./rot_x]
  [../]
  [./rot_y]
  [../]
  [./rot_z]
  [../]
[]

[AuxVariables]
  [./vel_x]
  [../]
  [./vel_y]
  [../]
  [./vel_z]
  [../]
  [./accel_x]
  [../]
  [./accel_y]
  [../]
  [./accel_z]
  [../]
  [./rot_vel_x]
  [../]
  [./rot_vel_y]
  [../]
  [./rot_vel_z]
  [../]
  [./rot_accel_x]
  [../]
  [./rot_accel_y]
  [../]
  [./rot_accel_z]
  [../]
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_y rot_x rot_z'
    area = 32.3363
    Iy = 568.6904
    Iz = 568.6904
    Ay = 60.987522
    Az = 60.987522
    y_orientation = '0.0 1.0 0.0'
    zeta = 1.3986E-5
  [../]
[]

[Kernels]
  [./inertial_force_x]
    type = InertialForceBeam
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'
    beta = 0.25
    gamma = 0.5
    area = 32.3363
    Iy = 568.6904
    Iz = 568.6904
    Ay = 60.987522
    Az = 60.987522
    component = 0
    variable = disp_x
    eta = 40.9536
  [../]
  [./inertial_force_y]
    type = InertialForceBeam
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'
    beta = 0.25
    gamma = 0.5
    area = 32.3363
    Iy = 568.6904
    Iz = 568.6904
    Ay = 60.987522
    Az = 60.987522
    component = 1
    variable = disp_y
    eta = 40.9536
  [../]
  [./inertial_force_z]
    type = InertialForceBeam
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'
    beta = 0.25
    gamma = 0.5
    area = 32.3363
    Iy = 568.6904
    Iz = 568.6904
    Ay = 60.987522
    Az = 60.987522
    component = 2
    variable = disp_z
    eta = 40.9536
  [../]
  [./inertial_force_rot_x]
    type = InertialForceBeam
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'
    beta = 0.25
    gamma = 0.5
    area = 32.3363
    Iy = 568.6904
    Iz = 568.6904
    Ay = 60.987522
    Az = 60.987522
    component = 3
    variable = rot_x
    eta = 40.9536
  [../]
  [./inertial_force_rot_y]
    type = InertialForceBeam
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'
    beta = 0.25
    gamma = 0.5
    area = 32.3363
    Iy = 568.6904
    Iz = 568.6904
    Ay = 60.987522
    Az = 60.987522
    component = 4
    variable = rot_y
    eta = 40.9536
  [../]
  [./inertial_force_rot_z]
    type = InertialForceBeam
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'
    beta = 0.25
    gamma = 0.5
    area = 32.3363
    Iy = 568.6904
    Iz = 568.6904
    Ay = 60.987522
    Az = 60.987522
    component = 5
    variable = rot_z
    eta = 40.9536
  [../]
  [./gravity]
    type = Gravity
    variable = disp_y
    value = -9810
    enable = false # gravity? ... I don't think it works well with LineElementMaster
  [../]
[]

[AuxKernels]
  [./accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
    execute_on = TIMESTEP_END
  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.5
    execute_on = TIMESTEP_END
  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.25
    execute_on = TIMESTEP_END
  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.5
    execute_on = TIMESTEP_END
  [../]
  [./accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    beta = 0.25
    execute_on = TIMESTEP_END
  [../]
  [./vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    gamma = 0.5
    execute_on = TIMESTEP_END
  [../]
  [./rot_accel_x]
    type = NewmarkAccelAux
    variable = rot_accel_x
    displacement = rot_x
    velocity = rot_vel_x
    beta = 0.25
    execute_on = TIMESTEP_END
  [../]
  [./rot_vel_x]
    type = NewmarkVelAux
    variable = rot_vel_x
    acceleration = rot_accel_x
    gamma = 0.5
    execute_on = TIMESTEP_END
  [../]
  [./rot_accel_y]
    type = NewmarkAccelAux
    variable = rot_accel_y
    displacement = rot_y
    velocity = rot_vel_y
    beta = 0.25
    execute_on = TIMESTEP_END
  [../]
  [./rot_vel_y]
    type = NewmarkVelAux
    variable = rot_vel_y
    acceleration = rot_accel_y
    gamma = 0.5
    execute_on = TIMESTEP_END
  [../]
  [./rot_accel_z]
    type = NewmarkAccelAux
    variable = rot_accel_z
    displacement = rot_z
    velocity = rot_vel_z
    beta = 0.25
    execute_on = TIMESTEP_END
  [../]
  [./rot_vel_z]
    type = NewmarkVelAux
    variable = rot_vel_z
    acceleration = rot_accel_z
    gamma = 0.5
    execute_on = TIMESTEP_END
  [../]
[]

[Functions]
  [./ground_displacement]
    type = ParsedFunction
    value = 'if(t<0.1, 5.1*sin(pi*t/0.025), 0*t)'
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
  [fixrx]
    type = PresetBC
    variable = rot_x
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
  [../]
  [fixry]
    type = PresetBC
    variable = rot_y
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
  [../]
  [fixrz]
    type = PresetBC
    variable = rot_z
    boundary = 'support_a support_b support_c support_d'
    value = 0.0
  [../]
  [./induce_displacement]
    type = FunctionPresetBC
    variable = disp_y
    boundary = 'support_a support_b support_c support_d'
    function = ground_displacement
    enable = false
  [../]
  [./induce_predisplacement]
    type = PresetDisplacement
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    boundary = 'support_a support_b support_c support_d'
    function = ground_displacement
    beta = 0.25
    enable = true
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
    outputs = exodus
    output_properties = 'forces moments'
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
