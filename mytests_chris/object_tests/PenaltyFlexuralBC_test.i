[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  # r_outer = 5.36 , r_inner = 4.76
  type = FileMesh
  file = fuel_cladding.e
  allow_renumbering = false
  partitioner = parmetis
  construct_node_list_from_side_list = false
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = true
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
  [./force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = midsection
    enable = true # apply_force=true
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = -19.5313 # total_load/no_nodes=2500N/128node=19.5313N/node
  [../]
[]

[BCs]
  [./pinx]
    type = PenaltyFlexuralBC
    variable = disp_x
    axis_origin = '0 0 0'
    axis_direction = '0 0 1'
    transverse_direction = '0 1 0'
    component = 0
    penalty = 1.0e+08
    boundary = 'left right'
  [../]
  [./piny]
    type = PenaltyFlexuralBC
    variable = disp_y
    axis_origin = '0 0 0'
    axis_direction = '0 0 1'
    transverse_direction = '0 1 0'
    component = 1
    penalty = 1.0e+08
    boundary = 'left right'
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
    poissons_ratio = 0.37
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
  petsc_options = '-ksp_snes_ew -snes_monitor -snes_linesearch_monitor -snes_converged_reason'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
