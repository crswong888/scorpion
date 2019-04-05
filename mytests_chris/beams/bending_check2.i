# Bending of a very thick and short beam

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1
  xmin = 0.0000
  xmax = 10.0000
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'

    # Geometry parameters
    area = 1.0000E3
    Iy = 8.3333E7
    Iz = 8.3333E7
    y_orientation = '0 1 0'
  [../]
[]

[MeshModifiers]
[]

[NodalKernels]
  [./force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = right
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = -1.0000E9
  [../]
[]

[BCs]
  [./fixx]
    type = PresetBC
    variable = disp_x
    boundary = left
    value = 0.0
  [../]
  [./fixy]
    type = PresetBC
    variable = disp_y
    boundary = left
    value = 0.0
  [../]
  [./fixz]
    type = PresetBC
    variable = disp_z
    boundary = left
    value = 0.0
  [../]
  [./fixrx]
    type = PresetBC
    variable = rot_x
    boundary = left
    value = 0.0
  [../]
  [./fixry]
    type = PresetBC
    variable = rot_y
    boundary = left
    value = 0.0
  [../]
  [./fixrz]
    type = PresetBC
    variable = rot_z
    boundary = left
    value = 0.0
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 2.0000E7
    poissons_ratio = 0.3500
    shear_coefficient = 0.8333
  [../]
  [./stress]
    type = ComputeBeamResultants
    outputs = exodus
    output_properties = 'forces moments'
  [../]
[]

[Postprocessors]
  [./max_disp]
    type = NodalMaxValue
    variable = disp_y
    boundary = right
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
  line_search = none
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
