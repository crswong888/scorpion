[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 4
  xmin = 0.0
  xmax = 200.0
[]

[MeshModifiers]
  [./mid_point]
    type = AddExtraNodeset
    coord = 100.0
    new_boundary = mid_point
  [../]
  [./q_point1]
    type = AddExtraNodeset
    coord = 50.0
    new_boundary = q_point_1
  [../]
  [./q_point2]
    type = AddExtraNodeset
    coord = 150.0
    new_boundary = q_point_2
  [../]


  [./span1]
    type = SubdomainBoundingBox
    top_right = '50 0 0'
    bottom_left = '0 0 0'
    block_id = 1
  [../]
  [./span2]
    type = SubdomainBoundingBox
    top_right = '100 0 0'
    bottom_left = '50 0 0'
    block_id = 2
  [../]
  [./span3]
    type = SubdomainBoundingBox
    top_right = '150 0 0'
    bottom_left = '100 0 0'
    block_id = 3
  [../]
  [./span4]
    type = SubdomainBoundingBox
    top_right = '200 0 0'
    bottom_left = '150 0 0'
    block_id = 4
  [../]
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'

    # Geometry parameters
    area = 32.3336
    Iy = 568.6904
    Iz = 568.6904
    y_orientation = '0.0 1.0 0.0'
  [../]
[]

[NodalKernels]
  [./force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = mid_point
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = -2.5E3
  [../]
[]

[BCs]
  [./fixx]
    type = PresetBC
    variable = disp_x
    boundary = 'left right'
    value = 0.0
  [../]
  [./fixy]
    type = PresetBC
    variable = disp_y
    boundary = 'left right'
    value = 0.0
  [../]
  [./fixz]
    type = PresetBC
    variable = disp_z
    boundary = 'left right'
    value = 0.0
  [../]
  [./fixrx]
    type = PresetBC
    variable = rot_x
    boundary = 'left right'
    value = 0.0
  [../]
  [./fixry]
    type = PresetBC
    variable = rot_y
    boundary = 'left right'
    value = 0.0
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 117211
    poissons_ratio = 0.355
    shear_coefficient = 0.5397
  [../]
  [./stress]
    type = ComputeBeamResultants
    outputs = exodus
    output_properties = 'forces moments'
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
    boundary = mid_point
  [../]
  [./force_y]
    type = FunctionValuePostprocessor
    function = load
  [../]
  [./rot_left]
    type = NodalMaxValue
    variable = rot_z
    boundary = left
  [../]
  [./rot_right]
    type = NodalMaxValue
    variable = rot_z
    boundary = right
  [../]

  [./mom_1]
    type = ElementExtremeValue
    value_type = min
    variable = moments_z
    block = 1
  [../]
  [./mom_2]
    type = ElementExtremeValue
    value_type = min
    variable = moments_z
    block = 2
  [../]
  [./mom_3]
    type = ElementExtremeValue
    value_type = min
    variable = moments_z
    block = 3
  [../]
  [./mom_4]
    type = ElementExtremeValue
    value_type = min
    variable = moments_z
    block = 4
  [../]
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
