# Case 1: Cladding only length of 10 pellets (128.8-mm)
# Tests Case 1 - Static axial loading using a 3D annular mesh

# Material properties are of unirradiated, in-tact Zr-4 cladding.

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  #file = fuel_cladding.e
  file = fuel_cladding_fine.e
  construct_node_list_from_side_list = false
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = true
    volumetric_locking_correction = true
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
    enable = true # apply point force=true
  [../]
[]

[Functions]
  [./point_load]
    type = ConstantFunction
    value = -2500
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
    enable = true # pin=false, fix=true
  [../]
  [./fixy]
    type = PresetBC
    variable = disp_y
    boundary = 'left right'
    value = 0.0
    enable = true # pin=false, fix=true
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
    poissons_ratio = 0.37 # not considering poisson's effect in this model
  [../]
  [./stress]
    type = ComputeLinearElasticStress
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
  csv = true
[]
