[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  file = Quad8_3D_deformed.e  # this creates a blank (0 stress) deformed mesh
                              # of the Quad8 model.
  partitioner = centroid
  centroid_partitioner_direction = y
[../]

[UserObjects]
  [./mat_soln]
    type = SolutionUserObject
    mesh = Quad8_3D_deformed.e
    system_variables = 'poissons_ratio youngs_modulus'
    timestep = LATEST
    execute_on = 'INITIAL'
  [../]
[]

[Functions]
  [./soln_func_poissons_ratio]
    type = Axisymmetric2D3DSolutionFunction
    solution = mat_soln
    from_variables = 'poissons_ratio'
  [../]
  [./soln_func_youngs_modulus]
    type = Axisymmetric2D3DSolutionFunction
    solution = mat_soln
    from_variables = 'youngs_modulus'
  [../]
  [./load]
    type = ConstantFunction
    value = 1.5932E8   # actually I want this to point in the negative
                       # direction, but it appears that the PressureBC object
  [../]                # points in the negative by default
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = true
  [../]
[]

[AuxVariables]
  ## store elastic moduli as nodal variables
  [./poissons_ratio]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./youngs_modulus]
    order = CONSTANT
    family = MONOMIAL
  [../]

  ## check elasticity tensor components for verification
  [./C_0011]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./C_1212]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./poissons_ratio]
    type = FunctionAux
    variable = poissons_ratio
    function = soln_func_poissons_ratio
    execute_on = 'INITIAL'
  [../]
  [./youngs_modulus]
    type = FunctionAux
    variable = youngs_modulus
    function = soln_func_youngs_modulus
    execute_on = 'INITIAL'
  [../]

  ## check elasticity tensor components for verification
  [./C_0011]
    type = RankFourAux
    rank_four_tensor = elasticity_tensor
    index_i = 0
    index_j = 0
    index_k = 1
    index_l = 1
    variable = C_0011
  [../]
  [./C_1212]
    type = RankFourAux
    rank_four_tensor = elasticity_tensor
    index_i = 1
    index_j = 2
    index_k = 1
    index_l = 2
    variable = C_1212
  [../]
[]

[Materials]
  [./elasticity_tesnors]
    type = VariableElasticModulus
    youngs_modulus = youngs_modulus
    poissons_ratio = poissons_ratio
  [../]
  [./stress]
    type = ComputeLinearElasticStress
  [../]
[]

[BCs]
  [./fixx]
    type = PresetBC
    variable = disp_x
    value = 0
    boundary = 'bottom top'
  [../]
  [./fixy]
    type = PresetBC
    variable = disp_y
    value = 0
    boundary = bottom
  [../]
  [./fixz]
    type = PresetBC
    variable = disp_z
    value = 0
    boundary = 'bottom top'
  [../]
  [./Pressure]
    [./compress_top]
      boundary = top
      function = load
    [../]
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
  num_steps = 1
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
