[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 1
  ny = 1
  nz = 1
  xmax = 1
  ymax = 1
  zmax = 1
[]

[Variables]
  [./disp_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_y]
    order = FIRST
    family = LAGRANGE
  [../]
  [./disp_z]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxVariables]
  [./vel_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./vel_y]
    order = FIRST
    family = LAGRANGE
  [../]
  [./vel_z]
    order = FIRST
    family = LAGRANGE
  [../]  
  [./accel_x]
    order = FIRST
    family = LAGRANGE
  [../]  
  [./accel_y]
    order = FIRST
    family = LAGRANGE
  [../]  
  [./accel_z]
    order = FIRST
    family = LAGRANGE
  [../]  
[]

[Kernels]
  [./InertialForce_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    gamma = 0.5
    beta = 0.25
  [../]
  [./InertialForce_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    gamma = 0.5
    beta = 0.25
  [../]
  [./InertialForce_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    gamma = 0.5
    beta = 0.25
  [../]
[]

[AuxKernels]
  [./accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.5
    execute_on = timestep_end
  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.5
    execute_on = timestep_end
  [../]
  [./vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    gamma = 0.5
    execute_on = timestep_end
  [../]
[]

[BCs]
  [./bottom_x]
    type = DirichletBC
    variable = disp_x
    boundary = bottom
    value = 0
  [../]
  [./bottom_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  [../]
  [./bottom_z]
    type = DirichletBC
    variable = disp_z
    boundary = bottom
    value = 0
  [../]
  [./top_x]
    type = DirichletBC
    variable = disp_x
    boundary = top
    value = 0
  [../]
  [./top_y]
    type = DirichletBC
    variable = disp_y
    boundary = top
    value = 0
  [../]
  [./top_z]
    type = FunctionDirichletBC
    variable = disp_z
    boundary = top
    function = forcing_load
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1.26e6
    poissons_ratio = 0.33
  [../]
  [./strain]
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y disp_z'
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    store_stress_old = True
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '0.00023832'
  [../]
[]

[Postprocessors]
  [./extreme_displacement]
    type = ElementExtremeValue
    variable = disp_z
  [../]
  [./forcing_load]
    type = FunctionValuePostprocessor
    function = forcing_load
  [../]
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  petsc_options_iname = 'ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomerang_max_iter'
  petsc_options_value = '201 hypre boomeramg 4'
  line_search = 'none'
  start_time = 0
  end_time = 1
  dt = 0.1
[]

[Functions]
  [./forcing_load]
    type = PiecewiseLinear
    x = '0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0'
    y = '0.0 0.000167 0.00133 0.0045 0.010667 0.020833 0.036 0.057167 0.0853 0.1215 0.1667'
  [../]
[]

[Outputs]
  exodus = true
  [./console]
    type = Console
    perf_graph = true
    output_linear = true
  [../]
[]
