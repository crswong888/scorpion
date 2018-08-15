# Case 1: Cladding only length of 2 pellets
# Tests Case 1 - Static using a line element mesh

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 8
  xmin = 0.0
  xmax = 25.76
[]

[MeshModifiers]
  [./mid_point]
    type = AddExtraNodeset
    coord = '12.88'
    new_boundary = middle
  [../]
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'

    # Geometry parameters
    area = 19.0758
    Iy = 4.7689
    Iz = 4.7689
    y_orientation = '0.0 1.0 0.0'
  [../]
[]

[NodalKernels]
  [./force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = middle
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = 25.0
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
  [./fixrx1]
    type = DirichletBC
    variable = rot_x
    boundary = left
    value = 0.0
  [../]
  [./fixry1]
    type = DirichletBC
    variable = rot_y
    boundary = left
    value = 0.0
  [../]
  [./fixy2]
    type = DirichletBC
    variable = disp_y
    boundary = right
    value = 0.0
  [../]
  [./fixz2]
    type = DirichletBC
    variable = disp_z
    boundary = right
    value = 0.0
  [../]
  [./fixrx2]
    type = DirichletBC
    variable = rot_x
    boundary = right
    value = 0.0
  [../]
  [./fixry2]
    type = DirichletBC
    variable = rot_y
    boundary = right
    value = 0.0
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 9.9300e4
    poissons_ratio = 0.37
    shear_coefficient = 0.8915
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
  [./disp_x]
    type = PointValue
    point = '12.88 0.0 0.0'
    variable = disp_x
  [../]
  [./disp_y]
    type = PointValue
    point = '12.88 0.0 0.0'
    variable = disp_y
  [../]
  [./force]
    type = FunctionValuePostprocessor
    function = load
  [../]
[]

[Outputs]
  exodus = true
[]
