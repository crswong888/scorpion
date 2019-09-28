[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  file = PenaltyFlexuralBC_test_mesh.e
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
    total_area_userobject = total_area
    enable = true # apply point force=true
  [../]
[]

[Functions]
  [./point_load]
    type = ConstantFunction
    value = -5500
  [../]
[]

[UserObjects]
  [./nodal_area]
    type = NodalArea
    variable = nodal_area
    boundary = midsection
    execute_on = 'INITIAL LINEAR'
  [../]
  [./total_area]
    type = NodalSumUserObject
    sum_from_variable = nodal_area
    boundary = midsection
    execute_on = 'INITIAL LINEAR'
  [../]
[]

[BCs]
  [./pinx]
    type = PenaltyFlexuralBC
    variable = disp_x
    neutral_axis_origin = '0.75 0 0'
    transverse_direction = '0 1 0'
    component = 0
    penalty = 1.0e+08
    boundary = 'right'
  [../]
  [./piny]
    type = PenaltyFlexuralBC
    variable = disp_y
    neutral_axis_origin = '0.75 0 0'
    transverse_direction = '0 1 0'
    component = 1
    penalty = 1.0e+08
    boundary = 'right'
  [../]
  [./fixx]
    type = PresetBC
    variable = disp_z
    boundary = 'left'
    value = 0.0
  [../]
  [./fixy]
    type = PresetBC
    variable = disp_z
    boundary = 'left'
    value = 0.0
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
    youngs_modulus = 200e09 # steel young's modulus
    poissons_ratio = 1e-09 # not considering poisson's effect in this model
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    #outputs = exodus
    #output_properties = stress
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 8000 # Approximate density of steel
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
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
