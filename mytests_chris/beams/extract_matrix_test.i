[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 4
  xmin = 0.0
  xmax = 200.0
[]

[MeshModifiers]
  [./mid_point]
    type = AddExtraNodeset
    coord = 100.0
    new_boundary = mid_point
  [../]
  [./q_point1]
    type = AddExtraNodeset
    coord = 50.0
    new_boundary = q_point_1
  [../]
  [./q_point2]
    type = AddExtraNodeset
    coord = 150.0
    new_boundary = q_point_2
  [../]


  [./span1]
    type = SubdomainBoundingBox
    top_right = '50 0 0'
    bottom_left = '0 0 0'
    block_id = 1
  [../]
  [./span2]
    type = SubdomainBoundingBox
    top_right = '100 0 0'
    bottom_left = '50 0 0'
    block_id = 2
  [../]
  [./span3]
    type = SubdomainBoundingBox
    top_right = '150 0 0'
    bottom_left = '100 0 0'
    block_id = 3
  [../]
  [./span4]
    type = SubdomainBoundingBox
    top_right = '200 0 0'
    bottom_left = '150 0 0'
    block_id = 4
  [../]
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'

    # Geometry parameters
    area = 32.3336
    Iy = 568.6904
    Iz = 568.6904
    Ix = 568.6904
    y_orientation = '0.0 1.0 0.0'

    # dynamic simulation using consistent mass/inertia matrix
    dynamic_consistent_inertia = true

    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'

    density = 'density'
    beta = 1.0 # Newmark time integration parameter
    gamma = 1.0 # Newmark time integration parameter

    # optional parameters for numerical (alpha) and Rayleigh damping
    alpha = 0.0 # HHT time integration parameter
    eta = -1.0 # Mass proportional Rayleigh damping
    zeta = 0.0 # Stiffness proportional Rayleigh damping
  [../]
[]

[NodalKernels]
  [./force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = mid_point
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = 1
  [../]
[]

[BCs]
  [./fixx]
    type = PresetBC
    variable = disp_x
    boundary = 'left right'
    value = 0.0
  [../]
  [./fixy]
    type = PresetBC
    variable = disp_y
    boundary = 'left right'
    value = 0.0
  [../]
  [./fixz]
    type = PresetBC
    variable = disp_z
    boundary = 'left right'
    value = 0.0
  [../]
  [./fixrx]
    type = PresetBC
    variable = rot_x
    boundary = 'left right'
    value = 0.0
  [../]
  [./fixry]
    type = PresetBC
    variable = rot_y
    boundary = 'left right'
    value = 0.0
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

[Executioner]
  type = Transient
  solve_type = FD
  num_steps = 1
  dt = 1.0
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
  [./DOFMap]
    type = DOFMap
    execute_on = FINAL
  [../]
[]
