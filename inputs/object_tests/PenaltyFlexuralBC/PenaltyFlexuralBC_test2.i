[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  file = ../quadruple_brick_beam.e
  allow_renumbering = false
  construct_node_list_from_side_list = false
[]

[AuxVariables]
  [./nodal_area]
    order = FIRST
    family = LAGRANGE
  [../]
  [./stress_xx]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = True
  [../]
[]

[AuxKernels]
  [./stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
    execute_on = 'LINEAR NONLINEAR'
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
    enable = true # apply point force=true
  [../]
[]

[Functions]
  [./point_load]
    type = ConstantFunction
    value = -1e+04
  [../]
[]

[UserObjects]
  [./nodal_area]
    type = NodalArea
    variable = nodal_area
    boundary = midsection
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  [../]
[]

[BCs]
  #
  [./flexx]
    # circular displacement constraint
    type = PenaltyFlexuralBC
    variable = disp_x
    component = 0
    internal_ref_point = '0 0 0'
    neutral_axis_origin = '0.75 0 0'
    axis_direction = '0 0 1'
    normal_stress = stress_xx
    penalty = 1e+08
    boundary = 'right'
    enable = true
    use_displaced_mesh = false
  [../]
  [./flexy]
    type = PenaltyFlexuralBC
    variable = disp_y
    component = 1
    internal_ref_point = '0 0 0'
    neutral_axis_origin = '0.75 0 0'
    axis_direction = '0 0 1'
    normal_stress = stress_xx
    penalty = 1e+08
    boundary = 'right'
    enable = true
    use_displaced_mesh = false
  [../]

  # centerline simple pins
  [./pinx]
    type = PresetBC
    variable = disp_x
    boundary = 'middle_left middle_right'
    value = 0.0
  [../]
  [./piny]
    type = PresetBC
    variable = disp_y
    boundary = 'middle_left middle_right'
    value = 0.0
  [../]

  # fixed translations
  [./fixx]
    type = PresetBC
    variable = disp_x
    boundary = 'left'
    value = 0.0
    enable = true
  [../]
  [./fixy]
    type = PresetBC
    variable = disp_y
    boundary = 'left'
    value = 0.0
    enable = true
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
    value_type = min # min since displacement is in negative direction
    variable = disp_y
    boundary = midsection
  [../]
  [./midsection_area]
    type = AreaPostprocessor
    boundary = midsection
    execute_on = 'INITIAL TIMESTEP_BEGIN'
    outputs = none
  [../]
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
