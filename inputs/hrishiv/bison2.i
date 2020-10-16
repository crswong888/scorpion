[GlobalParams]
displacements = "disp_x disp_y disp_z"
[]

[Mesh]
  type =FileMesh
  file = Single.inp
  construct_node_list_from_side_list = false
  construct_side_list_from_node_list = false
[]



  [Modules/TensorMechanics/Master]
    [./all]
      strain = SMALL
      add_variables = true
      displacements = "disp_x disp_y disp_z"
      generate_output = "strain_xx strain_yy strain_zz stress_xx stress_yy stress_zz"
    [../]
  []

[Materials]
#  [./fuel_elasticity_tensor]
#    type = UO2ElasticityTensor
  #  block = pellet
#    matpro_youngs_modulus = false #2e11
#    matpro_poissons_ratio = false #0.31
  #  temperature = temp
#  [../]

[./elasticity_tensor]
  type = ComputeIsotropicElasticityTensor
  youngs_modulus = 2e11
  poissons_ratio = 0
[../]
  [./elastic_stress]
    type = ComputeLinearElasticStress
    exodus = true
  #  block = pellet
  [../]
[]

[Functions]
  [./force]
    type = ParsedFunction
    value = 'if(t<10, -1e3*sin(pi*t), 0*t)'
    [../]
[]

[NodalKernels]
  [./load]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = force
    boundary = top
  [../]
[]

[BCs]
  [./fixx1]
    type = DirichletBC
    variable = disp_x
    boundary = top_n
    value = 0.0
  [../]
  [./fixy1]
    type = DirichletBC
    variable = disp_y
    boundary = top_n
    value = 0.0
  [../]
  [./fixz1]
    type = DirichletBC
    variable = disp_z
    boundary = top_n
    value = 0.0
  [../]
  [./fixx2]
    type = DirichletBC
    variable = disp_x
    boundary = bottom_n
    value = 0.0
  [../]
  [./fixy2]
    type = DirichletBC
    variable = disp_y
    boundary =bottom_n
    value = 0.0
  [../]
  [./fixz2]
    type = DirichletBC
    variable = disp_x
    boundary = bottom_n
    value = 0.0
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  #  petsc_options = "-snes_ksp_ew"
    petsc_options_iname = "-ksp_type -pc_type -sub_pc_type -snes_atol -snes_rtol -snes_max_it -ksp_atol -ksp_rtol -sub_pc_factor_shift_type"
    petsc_options_value = "gmres asm lu 1e-8 1e-8 25 1e-8 1e-8 NONZERO"
  [../]
[]

[Executioner]
  type = Transient
  solve_type = Newton
  dt = 0.01
  start_time = 0
  end_time = 20
#  petsc_options = '-snes_ksp_ew'
#  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
#  petsc_options_value = 'asm lu 1 101'
[]
[Postprocessors]
  [./disp_max]
    type = NodalMaxValue
    variable = disp_y
    boundary = top
  [../]
  [./force_y]
    type = FunctionValuePostprocessor
    function = force
  [../]
  [./d_element]
    type = ElementalVariableValue
    variable = disp_y
    elementid = 2795
  [../]
  []

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
