# A test for specifying the time history data directly in the input file

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = GeneratedMesh # Can generate simple lines, rectangles and rectangular prisms
  dim = 3 # Dimension of the mesh
  nx = 1 # Number of elements in the x direction
  ny = 1 # Number of elements in the y direction
  nz = 1 # Number of elements in the z direction
  xmin = 0.0
  xmax = 1
  ymin = 0.0
  ymax = 1
  zmin = 0.0
  zmax = 1
[]


[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]

[AuxVariables]
  [vel_x]
  []
  [accel_x]
  []
  [vel_y]
  []
  [accel_y]
  []
  [vel_z]
  []
  [accel_z]
  []
  [stress_xy]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_yz]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_zx]
    order = CONSTANT
    family = MONOMIAL
  []
  [strain_xy]
    order = CONSTANT
    family = MONOMIAL
  []
  [strain_yz]
    order = CONSTANT
    family = MONOMIAL
  []
  [strain_zx]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress_zz]
    order = CONSTANT
    family = MONOMIAL
  []
  [strain_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [strain_yy]
    order = CONSTANT
    family = MONOMIAL
  []
  [strain_zz]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [DynamicTensorMechanics]
    displacements = 'disp_x disp_y disp_z'
  []
  [inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.25
    gamma = 0.5
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.25
    gamma = 0.5
  []
  [inertia_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    beta = 0.25
    gamma = 0.5
  []
[]

[AuxKernels]
  [accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
    execute_on = timestep_end
  []
  [vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.5
    execute_on = timestep_end
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.25
    execute_on = timestep_end
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.5
    execute_on = timestep_end
  []
  [accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    beta = 0.25
    execute_on = timestep_end
  []
  [vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    gamma = 0.5
    execute_on = timestep_end
  []
  [stress_xy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xy
    index_i = 1
    index_j = 0
  []
  [stress_yz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yz
    index_i = 2
    index_j = 1
  []
  [stress_zx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zx
    index_i = 0
    index_j = 2
  []
  [strain_xy]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = stress_xy
    index_i = 1
    index_j = 0
  []
  [strain_yz]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_yz
    index_i = 2
    index_j = 1
  []
  [strain_zx]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_zx
    index_i = 0
    index_j = 2
  []
  [stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
  []
  [stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
  []
  [stress_zz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zz
    index_i = 2
    index_j = 2
  []
  [strain_xx]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_xx
    index_i = 0
    index_j = 0
  []
  [strain_yy]
    type = RankTwoAux
    rank_two_tensor =total_strain
    variable = strain_yy
    index_i = 1
    index_j = 1
  []
  [strain_zz]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_zz
    index_i = 2
    index_j = 2
  []
[]

[Functions]
  [ground_accel]
    type = BaselineCorrection
    time_values =         '  0.00    0.01     0.02     0.03     0.04     0.05     0.06    0.07   0.08     0.09      0.10      0.11      0.12      0.13      0.14     0.15   0.16'
    acceleration_values = '0.0000 57.4025 106.0660 138.5819 150.0000 138.5819 106.0660 57.4025 0.0000 -57.4025 -106.0660 -138.5819 -150.0000 -138.5819 -106.0660 -57.4025 0.0000'
    gamma = 0.5
    beta = 0.25
    order = 2
    scale_factor = 2.5
  []
[]

[ICs]
  [initial_ground_accel]
    type = FunctionIC
    variable = accel_x
    function = ground_accel
    boundary = bottom
  []
[]

[BCs]
  [fixx]
    type = DirichletBC
    variable = disp_x
    boundary = bottom
    value = 0.0
  []
  [fixy]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0.0
  []
  [fixz]
    type = DirichletBC
    variable = disp_z
    boundary = bottom
    value = 0.0
  []
  [Periodic]
    [x_dir]
      variable = 'disp_x disp_y disp_z'
      primary = '4'
      secondary = '2'
      translation = '1.0 0.0 0.0'
    []
    [y_dir]
      variable = 'disp_x disp_y disp_z'
      primary = '1'
      secondary = '3'
      translation = '0.0 1.0 0.0'
    []
  []
  [induce_acceleration]
    type = PresetAcceleration
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    boundary = bottom
    function = ground_accel
    beta = 0.25
  []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 200e09 # Pa, steel young's modulus
    poissons_ratio = 0.3
  []
  [small_strain]
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y disp_z'
  []
  [elastic_stress]
    type = ComputeLinearElasticStress
  []
  [steel_density]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 8050 # kg/m^3
  []
[]

[Controls]
  [release_ground]
    type = TimePeriod
    start_time = 0.0
    end_time = 0.16
    disable_objects = */fixx
  []
  [stop_ground_accel]
    type = TimePeriod
    start_time = 0.16
    disable_objects = */induce_acceleration
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  nl_rel_tol = 1e-06
  nl_abs_tol = 1e-08
  l_tol = 1e-12
  start_time = 0.00
  end_time = 0.25
  dt = 0.01
  dtmin = 0.01
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'
[]

[Postprocessors]
  [check_func_value]
    type = FunctionValuePostprocessor
    function = ground_accel
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [disp_ground]
    type = NodalMaxValue
    variable = disp_x
    boundary = bottom
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [vel_ground]
    type = NodalMaxValue
    variable = vel_x
    boundary = bottom
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [accel_ground]
    type = NodalMaxValue
    variable = accel_x
    boundary = bottom
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Outputs]
  exodus = true
  csv = true
[]
