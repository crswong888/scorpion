[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  rotations = 'rot_x rot_y rot_z'
[]

[Mesh]
  type = FileMesh
  file = simple_beam_10m.e
  allow_renumbering = false
[]

[AuxVariables]
  [./moment_z]
    order = FIRST
    family = MONOMIAL
  [../]
[]

[Modules/TensorMechanics/LineElementMaster]
  [./simple_beam]
    add_variables = true
    area = 0.090
    Iy = 6.75e-04
    Iz = 6.75e-04
    y_orientation = '0 1 0'
  [../]
[]

[AuxKernels]
  [./moment_z]
    type = MaterialRealVectorValueAux
    property = moments
    variable = moment_z
    component = 2
  [../]
[]


[NodalKernels]
  [./apply_force]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = point_load
    boundary = mid
  [../]
[]

[Functions]
  [./point_load]
    type = ConstantFunction
    value = -5.00e+04
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
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 200e+09
    poissons_ratio = 0.350
    shear_coefficient = 0.833
  [../]
  [./stress]
    type = ComputeBeamResultants
    outputs = exodus
    output_properties = 'forces moments'
  [../]
  [./nodal_moment]
    type = PiecewiseLinearInterpolationMaterial
    property = nodal_moment
    variable = rot_z
    xy_data = '0 0
               0.5 0'
    outputs = all
    output_properties = nodal_moment
  [../]
[]

[Postprocessors]
  [./max_disp]
    type = NodalMaxValue
    variable = disp_y
    boundary = mid
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
  solve_type = NEWTON
  scheme = explicit-euler
  num_steps = 1
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
