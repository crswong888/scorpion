[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  file = Spacer_with_sets.inp
  construct_node_list_from_side_list = false
[]

[MeshModifiers]
  [./make3D]
    type = MeshExtruder
    extrusion_vector = '0 0 0'
    existing_subdomains = '0'
  [../]
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
    boundary = Middle
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = 2500
  [../]
[]

[BCs]
  [fixx]
    type = PresetBC
    variable = 'disp_x'
    boundary = 'Right Left'
    value = 0.0
  [../]
  [fixy]
    type = PresetBC
    variable = 'disp_y'
    boundary = 'Right Left'
    value = 0.0
  [../]
  [fixz]
    type = PresetBC
    variable = 'disp_z'
    boundary = 'Right Left'
    value = 0.0
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 200E6
    poissons_ratio = 0.3
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    #outputs = exodus
    #output_properties = stress
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
[]

[Postprocessors]
  [./disp_y]
    type = NodalMaxValue
    variable = disp_y
    boundary = Middle
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
