[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1
  xmin = 0.0
  xmax = 10000.0
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
    y_orientation = '0.0 1.0 0.0'

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
  [./force_x]
    type = UserForcingFunctionNodalKernel
    variable = disp_x
    function = load
    boundary = 'left right'
  [../]
  [./force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = 'left right'
  [../]
  [./force_z]
    type = UserForcingFunctionNodalKernel
    variable = disp_z
    function = load
    boundary = 'left right'
  [../]
  [./force_rx]
    type = UserForcingFunctionNodalKernel
    variable = rot_x
    function = load
    boundary = 'left right'
  [../]
  [./force_ry]
    type = UserForcingFunctionNodalKernel
    variable = rot_y
    function = load
    boundary = 'left right'
  [../]
  [./force_rz]
    type = UserForcingFunctionNodalKernel
    variable = rot_z
    function = load
    boundary = 'left right'
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = 1
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 117211
    poissons_ratio = 0.355
    shear_coefficient = 1
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

[Postprocessors]
  [./disp_x1]
    type = NodalMaxValue
    variable = disp_x
    boundary = left
  [../]
  [./disp_y1]
    type = NodalMaxValue
    variable = disp_y
    boundary = left
  [../]
  [./disp_z1]
    type = NodalMaxValue
    variable = disp_z
    boundary = left
  [../]
  [./rot_x1]
    type = NodalMaxValue
    variable = rot_x
    boundary = left
  [../]
  [./rot_y1]
    type = NodalMaxValue
    variable = rot_y
    boundary = left
  [../]
  [./rot_z1]
    type = NodalMaxValue
    variable = rot_z
    boundary = left
  [../]
  [./disp_x2]
    type = NodalMaxValue
    variable = disp_x
    boundary = right
  [../]
  [./disp_y2]
    type = NodalMaxValue
    variable = disp_y
    boundary = right
  [../]
  [./disp_z2]
    type = NodalMaxValue
    variable = disp_z
    boundary = right
  [../]
  [./rot_x2]
    type = NodalMaxValue
    variable = rot_x
    boundary = right
  [../]
  [./rot_y2]
    type = NodalMaxValue
    variable = rot_y
    boundary = right
  [../]
  [./rot_z2]
    type = NodalMaxValue
    variable = rot_z
    boundary = right
  [../]
[]

[Executioner]
  type = Transient
  scheme = explicit-euler
  solve_type = FD
  num_steps = 1
  line_search = none
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
