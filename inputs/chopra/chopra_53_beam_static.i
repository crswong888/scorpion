# Tests the stiffness for chopra_53_beam.i

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 16
  xmin = 0.0
  xmax = 25.0
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'

    # Geometry parameters
    area = 1.0
    Iy = 0.08333
    Iz = 0.08333
    y_orientation = '0.0 1.0 0.0'
  [../]
[]

[NodalKernels]
  [./force_y2]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    boundary = right
    function = force
  [../]
[]

[Functions]
  [./force]
    type = ConstantFunction
    value = 1.0
  [../]
[]

[BCs]
  [./fixx1]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0.0
  [../]
  [./fixy1]
    type = DirichletBC
    variable = disp_y
    boundary = left
    value = 0.0
  [../]
  [./fixz1]
    type = DirichletBC
    variable = disp_z
    boundary = left
    value = 0.0
  [../]
  [./fixr1]
    type = DirichletBC
    variable = rot_x
    boundary = left
    value = 0.0
  [../]
  [./fixr2]
    type = DirichletBC
    variable = rot_y
    boundary = left
    value = 0.0
  [../]
  [./fixr3]
    type = DirichletBC
    variable = rot_z
    boundary = left
    value = 0.0
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 1.1250e6
    poissons_ratio = 1e-9
    shear_coefficient = 0.8333
  [../]
  [./stress]
    type = ComputeBeamResultants
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
  solve_type = NEWTON
  line_search = 'none'
  nl_max_its = 15
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
  start_time = 0.0
  dt = 1.0
  end_time = 1.0
[]

[Postprocessors]
  [./disp_y]
    type = PointValue
    point = '25.0 0.0 0.0'
    variable = disp_y
  [../]
  [./force]
    type = FunctionValuePostprocessor
    function = force
  [../]
[]

[Outputs]
  exodus = true
[]
