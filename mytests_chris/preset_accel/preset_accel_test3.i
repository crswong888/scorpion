# PresetAccel test Case 3: a cantilever beam with accel BC applied at the free
# end. This is a damped model with a target ratio of 0.05. The mass is
# uniformly distributed along its length.

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 25
  xmin = 0
  xmax = 12.50 #ft
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
    area = 135 #in^2
    Iy = 2531.25 #in^4
    Iz = 2531.25 #in^4
    y_orientation = '0.0 1.0 0.0'

    # Newmark constant average acceleration parameters
    beta = 0.25
    gamma = 0.5

    # Rayleigh damping parameters (target 5% damping)
    eta = 6.4805E-1 # mass proportional damping
    zeta = 7.8787E-4 # stiffness proportional damping
  [../]
[]

[Functions]
  [./applied_accel]
    type = ParsedFunction
    value = 'if(t<5, -178*sin(3*pi*t), 0*t)' #in/s^2
  [../]
[]

[BCs]
  [./fixx]
    type = PresetBC
    variable = disp_x
    boundary = left
    value = 0.0
  [../]
  [./fixy]
    type = PresetBC
    variable = disp_y
    boundary = left
    value = 0.0
  [../]
  [./fixz]
    type = PresetBC
    variable = disp_z
    boundary = left
    value = 0.0
  [../]
  [fixrx]
    type = PresetBC
    variable = rot_x
    boundary = left
    value = 0.0
  [../]
  [fixry]
    type = PresetBC
    variable = rot_y
    boundary = left
    value = 0.0
  [../]
  [fixrz]
    type = PresetBC
    variable = rot_z
    boundary = left
    value = 0.0
  [../]

  [./induce_acceleration]
    type = PresetAcceleration
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    boundary = right
    function = applied_accel
    beta = 0.25
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 29E6 #psi
    poissons_ratio = 0.3
    shear_coefficient = 0.8497
  [../]
  [./stress]
    type = ComputeBeamResultants
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 0.2836 #pci
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
  dt = 0.025
  end_time = 10.0
  line_search = none

  [./TimeIntegrator]
    type = NewmarkBeta
    beta = 0.25
    gamma = 0.5
  [../]
[]

[Postprocessors]
  [./disp_free_end]
    type = NodalMaxValue
    variable = disp_y
    boundary = right
  [../]
  [./vel_free_end]
    type = NodalMaxValue
    variable = vel_y
    boundary = right
  [../]
  [./accel_free_end]
    type = NodalMaxValue
    variable = accel_y
    boundary = right
  [../]
[]

[Outputs]
  file_base = outputs/preset_accel_test3_out
  exodus = true
  csv = true
  perf_graph = true
[]
