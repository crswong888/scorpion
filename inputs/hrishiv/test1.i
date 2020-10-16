[GlobalParams]
  displacements= 'disp_x disp_y disp_z'
[]

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx =  10
  xmin = 0
  xmax = 10
[]

[MeshModifiers]
 [./mid_point]
   type = AddExtraNodeset
   new_boundary = mid_point
   coord = '5'
 [../]
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
   add_variables = true
   displacements = 'disp_x disp_y disp_z'
   rotations = 'rot_x rot_y rot_z'
   area = 0.01
   Iy = 1e-4
   Iz = 1e-4
   y_orientation = '0.0 1.0 0.0'
  [../]
[]


[NodalKernel]
  [./force_y]
   type = UserForcingFunctionNodalKernel
   variable = disp_y
   function = load
   boundary = mid_point
   enable = true
  [../]
[]

[Functions]
  [./load]
   type = ConstantFunction
   value = -1
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
  [./fixrz1]
    type = DirichletBC
    variable = rot_z
    boundary = left
    value = 0.0
  [../]
  [./fixx2]
    type = DirichletBC
    variable = disp_x
    boundary = right
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
  [./fixrz2]
    type = DirichletBC
    variable = rot_z
    boundary = right
    value = 0.0
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 1E4
    poissons_ratio = 1
    shear_coefficient = 1
    block = 0
  [../]
  [./stress]
    type = ComputeBeamResultants
    outputs = exodus
    output_properties = 'forces moments'
    block = 0
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
  solve_type = Newton
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
[]


[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
 
   




