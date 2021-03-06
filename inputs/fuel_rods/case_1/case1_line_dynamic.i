# Case 1: Cladding only length of 10 pellets (128.8-mm)
# Tests Case 1 - Dynamic impulse loading using a 1D line element mesh

# Material properties are of unirradiated, in-tact Zr-4 cladding.

# With (eta) = 996.7809 and (zeta) = 4.7603E-7, damping is 2.2% to 3% from 1st to 3rd mode 
# frequency of 3133.5193-Hz to 16926.5999-Hz, respectively. 

# These Rayleigh parameters are valid only for a fixed-fixed scenario

# Fastest with single processor

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 6
  xmin = 0.0
  xmax = 128.8
[]

[MeshModifiers]
  [./mid_point]
    type = AddExtraNodeset
    coord = '64.4'
    new_boundary = mid_point
  [../]
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'

    # Geometry parameters
    area = 19.0758
    Iy = 245.0624
    Iz = 245.0624
    y_orientation = '0.0 1.0 0.0'

    # dynamic simulation using consistent density/inertia matrix
    dynamic_consistent_inertia = True

    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'

    density = 'density'
    beta = 0.25 # Newmark time integraion parameter
    gamma = 0.5 # Newmark time integraion parameter

    # optional parameters for numerical (alpha) and Rayleigh damping
    alpha = 0.0 # HHT time integration parameter
    eta = 996.7809 # Mass proportional Rayleigh damping
    zeta = 4.7603E-7 # Stiffness proportional Rayleigh damping
  [../]
[]

[Kernels]
  [./gravity]
    type = Gravity
    variable = disp_y
    value = -9810
    enable = false # gravity? ... I don't think it works well with LineElementMaster
  [../]
[]

[NodalKernels]
  [./force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = mid_point
    enable = true # apply_force=true
  [../]
[]

[Functions]
  [./load]
    type = ParsedFunction
    value = 'if(t<0.002, -25.0*sin(pi*t/0.002), 0*t)'
  [../]
[]

[BCs]
  [./fixx1]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0.0
  [../]
  [./fixy1]
    type = DirichletBC
    variable = disp_y
    boundary = left
    value = 0.0
  [../]
  [./fixz1]
    type = DirichletBC
    variable = disp_z
    boundary = left
    value = 0.0
  [../]
  [./fixrx1]
    type = DirichletBC
    variable = rot_x
    boundary = left
    value = 0.0
  [../]
  [./fixry1]
    type = DirichletBC
    variable = rot_y
    boundary = left
    value = 0.0
  [../]
  [./fixrz1]
    type = DirichletBC
    variable = rot_z
    boundary = left
    value = 0.0
    enable = true # pin=false, fix=true
  [../]
  [./fixx2]
    type = DirichletBC
    variable = disp_x
    boundary = right
    value = 0.0
    enable = true # roller=false, fix=true
  [../]
  [./fixy2]
    type = DirichletBC
    variable = disp_y
    boundary = right
    value = 0.0
  [../]
  [./fixz2]
    type = DirichletBC
    variable = disp_z
    boundary = right
    value = 0.0
  [../]
  [./fixrx2]
    type = DirichletBC
    variable = rot_x
    boundary = right
    value = 0.0
  [../]
  [./fixry2]
    type = DirichletBC
    variable = rot_y
    boundary = right
    value = 0.0
  [../]
  [./fixrz2]
    type = DirichletBC
    variable = rot_z
    boundary = right
    value = 0.0
    enable = true # roller=false, fix=true
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 9.93E4
    poissons_ratio = 0.37
    shear_coefficient = 0.5392
  [../]
  [./stress]
    type = ComputeBeamResultants
    outputs = exodus
    output_properties = 'forces moments'
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 6.0E-9 # Approximate density of Zr-4
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
  dt = 1.0E-5
  end_time = 0.005
[]

[Postprocessors]
  [./disp_y]
    type = NodalMaxValue
    variable = disp_y
    boundary = mid_point
  [../]
  [./vel_y]
    type = NodalMaxValue
    variable = vel_y
    boundary = mid_point
  [../]
  [./accel_y]
    type = NodalMaxValue
    variable = accel_y
    boundary = mid_point
  [../]
  [./force_y]
    type = FunctionValuePostprocessor
    function = load
  [../]
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
