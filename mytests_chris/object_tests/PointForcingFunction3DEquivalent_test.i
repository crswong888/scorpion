[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  file = fuel_cladding.e
  allow_renumbering = false
  construct_node_list_from_side_list = false
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = True
  [../]
[]

[AuxVariables]
  [./nodal_area]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Kernels]
  [./gravity]
    type = Gravity
    variable = disp_y
    value = -9810
    enable = false # gravity=true
  [../]
[]

[NodalKernels]
  [./point_force_y]
    type = PointForcingFunction3DEquivalent
    variable = disp_y
    function = point_load
    boundary = midsection
    nodal_area = nodal_area
    total_area_postprocessor = midsection_area
    #total_area_userobject = total_area
    enable = true # apply point force=true
  [../]
  [./distributed_force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = distributed_load
    boundary = midsection
    enable = false # apply distributed force=true
  [../]
[]

[Functions]
  [./point_load]
    type = ConstantFunction
    value = -2500
  [../]
  [./distributed_load]
    type = ConstantFunction
    value = -19.5313 # total_load/no_nodes=2500N/128node=19.5313N/node
  [../]
[]

[NodalNormals]
  boundary = 'left right'
  order = FIRST
[]

[UserObjects]
  [./nodal_area]
    type = NodalArea
    variable = nodal_area
    boundary = midsection
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  [../]
  [./total_area]
    type = NodalSumUserObject
    sum_from_variable = nodal_area
    boundary = midsection
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  [../]
[]

[BCs]
  [./fixx_center]
    type = PresetBC
    variable = disp_x
    boundary = 'left_center right_center'
    value = 0.0
    enable = true
  [../]
  [./fixy_center]
    type = PresetBC
    variable = disp_y
    boundary = 'left_center right_center'
    value = 0.0
    enable = true
  [../]

  [./fixx]
    type = PresetBC
    variable = disp_x
    boundary = 'left right'
    value = 0.0
    enable = false # pin=false, fix=true
  [../]
  [./fixy]
    type = PresetBC
    variable = disp_y
    boundary = 'left right'
    value = 0.0
    enable = false # pin=false, fix=true
  [../]
  [./fixz]
    type = PresetBC
    variable = disp_z
    boundary = 'left right'
    value = 0.0
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 9.93e04
    poissons_ratio = 1e-9 # not considering poisson's effect in this model
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    #outputs = exodus
    #output_properties = stress
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 6.0e-09 # Approximate density of Zr-4
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  nl_rel_tol = 1e-04
  nl_abs_tol = 1e-06
  l_tol = 1e-08
  l_max_its = 250
  num_steps = 1
  timestep_tolerance = 1e-06
  petsc_options = '-ksp_snes_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'
[]

[Postprocessors]
  [./avg_disp_y]
    type = AverageNodalVariableValue
    variable = disp_y
    boundary = midsection
  [../]
  [./max_disp_y]
    type = NodalExtremeValue
    value_type = min
    variable = disp_y
    boundary = midsection
  [../]
  [./midsection_area]
    type = NodalSum
    variable = nodal_area
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  [../]
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
