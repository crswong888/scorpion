[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  file = inclined_bar.e
  allow_renumbering = false
  construct_node_list_from_side_list = false
[]

[AuxVariables]
  [./nodal_area]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[Modules/TensorMechanics/Master/All]
  add_variables = true
  strain = FINITE
[]

[NodalKernels]
  [./point_force_y]
    type = PointForcingFunction3DEquivalent
    variable = disp_y
    function = point_load
    boundary = midsection
    nodal_area = nodal_area
    total_area_postprocessor = midsection_area
  [../]
[]

[Functions]
  [./point_load]
    type = ConstantFunction
    value = -1e+06
  [../]
[]

[BCs]
  [./InclinedNoDisplacementBC]
    [./right]
      boundary = right
      penalty = 1e+08
    [../]
  [../]

  # fixed translations
  [./fixx]
    type = PresetBC
    variable = disp_x
    boundary = left
    value = 0.0
    enable = true
  [../]
  [./fixy]
    type = PresetBC
    variable = disp_y
    boundary = left
    value = 0.0
    enable = true
  [../]
  [./fixz]
    type = PresetBC
    variable = disp_z
    boundary = 'left right back front bottom top'
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
    type = ComputeFiniteStrainElasticStress
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

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  nl_rel_tol = 1e-04
  nl_abs_tol = 1e-06
  l_tol = 1e-08
  l_max_its = 250
  num_steps = 1
  timestep_tolerance = 1e-06
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'
[]

[Postprocessors]
  [./midsection_area]
    type = AreaPostprocessor
    boundary = midsection
    execute_on = 'INITIAL TIMESTEP_BEGIN'
    outputs = none
  [../]
[]

[Outputs]
  exodus = true
[]
