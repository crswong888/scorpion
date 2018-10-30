[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1
  xmin = 0.0
  xmax = 1.0
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    
    area = 1.0
    Iy = 1.0
    Iz = 1.0
    y_orientation = '0.0 1.0 0.0'

    dynamic_consistent_inertia = true

    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'

    density = 'density'
    beta = 0.25
    gamma = 0.5

    alpha = 0.0
    eta = 0.0
    zeta = 0.0

  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 1.0
    poissons_ratio = 1.0E-12
  [../]
  [./stress]
    type = ComputeBeamResultants
    outputs = exodus
    output_properties = 'forces moments'
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 1.0
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  start_time = 0.0
  dt = 1.0
  end_time = 1.0
  line_search = none
[]





