# ultimately, the periodic boundary condition as used here did not do anything
# to change the results as they would otherwise be

# the 3D pinned support situation is a bit more complicated than what the
# periodic bc can do

# there is nothing to couple disp_x to disp_y here, and that is the most
# important peice here

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  file = quadruple_brick_beam.e
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
    value = -5500
  [../]

  [./tr1_x]
    type = ParsedFunction
    value = -x
  [../]
  [./tr1_y]
    type = ParsedFunction
    value = -y
  [../]
  [./tr2_x]
    type = ParsedFunction
    value = -x
  [../]
  [./tr2_y]
    type = ParsedFunction
    value = y
  [../]
  [./tr_z]
    type = ParsedFunction
    value = z
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

  [./fixz]
    type = PresetBC
    variable = disp_z
    boundary = 'left right'
    value = 0.0
  [../]

  [./Periodic]
    [./x_left]
      variable = disp_x
      primary = bottom_left
      secondary = top_right
      transform_func = 'tr1_x tr1_y tr_z'
      inv_transform_func = 'tr1_x tr1_y tr_z'
    [../]
    [./x_right]
      variable = disp_x
      primary = bottom_right
      secondary = top_left
      transform_func = 'tr1_x tr1_y tr_z'
      inv_transform_func = 'tr1_x tr1_y tr_z'
    [../]
    [./y_left]
      variable = disp_y
      primary = bottom_left
      secondary = bottom_right
      transform_func = 'tr2_x tr2_y tr_z'
      inv_transform_func = 'tr2_x tr2_y tr_z'
    [../]
    [./y_right]
      variable = disp_y
      primary = top_right
      secondary = top_left
      transform_func = 'tr2_x tr2_y tr_z'
      inv_transform_func = 'tr2_x tr2_y tr_z'
    [../]
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
