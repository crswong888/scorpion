[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [generated_mesh]
    type = GeneratedMeshGenerator
    dim = 3
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    zmin = 0
    zmax = 1
    nx = 1
    ny = 1
    nz = 1
  []
[]

[BCs]
  [backx]
    type = DirichletBC
    boundary = bottom
    variable = disp_x
    value = 0.0
  []
  [backy]
    type = DirichletBC
    boundary = bottom
    variable = disp_y
    value = 0.0
  []
  [backz]
    type = DirichletBC
    boundary = bottom
    variable = disp_z
    value = 0.0
  []
  [apply_pressure]
    type = Pressure
    variable = disp_y
    component = 1
    boundary = top
    factor = -250000
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    add_variables = true
    generate_output = 'stress_xx stress_xy stress_yy stress_zz strain_xx strain_xy strain_yy strain_zz'
  []
[]

[Materials]
    [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    poissons_ratio = 0.3
    youngs_modulus = 200e9
  []
  [stress]
    type = ComputeLinearElasticStress
  []
[]

[Postprocessors]
  [disp_y]
    type = NodalExtremeValue
    variable = disp_y
    boundary = top
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  num_steps = 1
[]

[Outputs]
  csv = true
  exodus = true
[]
