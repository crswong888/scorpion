[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  file = grid1.inp
  displacements = 'disp_x disp_y disp_z'
  construct_side_list_from_node_list = true
  allow_renumbering = false
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = true
  [../]
[]

[NodalKernels]
  [./force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = 'Left-Free'
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = -0.2   # 60N/300NODE = 0.2N/NODEpea
  [../]
[]

[BCs]
  [fixx]
    type = PresetBC
    variable = 'disp_x'
    boundary = 'Right-Fixed'
    value = 0.0
  [../]
  [fixy]
    type = PresetBC
    variable = 'disp_y'
    boundary = 'Right-Fixed'
    value = 0.0
  [../]
  [fixz]
    type = PresetBC
    variable = 'disp_z'
    boundary = 'Right-Fixed'
    value = 0.0
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 9.93E4
    poissons_ratio = 0.318
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    outputs = exodus
    output_properties = stress
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
  solve_type = Newton
  scheme = explicit-euler
  num_steps = 1
  line_search = none
[]

[Postprocessors]
  [./disp_y]
    type = NodalExtremeValue
    value_type = max
    variable = disp_y
    boundary = 'Left-Free'
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

  [./Outputs]
    type = Exodus
  [../]
[]
