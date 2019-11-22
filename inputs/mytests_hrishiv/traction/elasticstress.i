[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 1
  ny = 1
  nz = 1
  xmin = -0.5
  xmax = 0.5
  ymin = -0.5
  ymax = 0.5
  zmin = -0.5
  zmax = 0.5
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = true
    incremental = true
    strain = finite
    generate_output = 'strain_zz stress_zz vonmises_stress plastic_strain_zz elastic_strain_zz'
  [../]
[]

[BCs]
  [./x]
    type = FunctionPresetBC
    variable = disp_x
    boundary = 'front back'
    function = '0'
  [../]
  [./y]
    type = FunctionPresetBC
    variable = disp_y
    boundary = 'front back'
    function = '0'
  [../]
  [./z]
    type = FunctionPresetBC
    variable = disp_z
    boundary = 'front back'
    function = '1E-6*z*t'
  [../]
[]

[AuxVariables]
  [./intnl]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./intnl_auxk]
    type = MaterialStdVectorAux
    property = plastic_internal_parameter
    index = 0
    variable = intnl
  [../]
[]

[Postprocessors]
  [./stress]
    type = PointValue
    point = '0 0 0'
    variable = stress_zz
  [../]
  [./strain]
    type = PointValue
    point = '0 0 0'
    variable = strain_zz
  [../]
  [./vonmises]
    type = PointValue
    point = '0 0 0'
    variable = vonmises_stress
  [../]
 [./estrain]
    type = PointValue
    point = '0 0 0'
    variable = elastic_strain_zz
  [../]
  [./pstrain]
    type = PointValue
    point = '0 0 0'
    variable = plastic_strain_zz
  [../]
 [./intnl]
  sssssssssssssssssssss  type = PointValue
    point = '0 0 0'
    variable = intnl
  [../]
[]

[UserObjects]
  #[./ts]
   # type = TensorMechanicsHardeningCubic
 #   value_0 = 2.0
  #  value_residual = 2.5
  #  internal_0 = 0
   # internal_limit = 0.000004
  #[../]

[./ts]
    type = TensorMechanicsHardeningPowerRule
    value_0 = 2
    epsilon0 = 0.00001
    exponent = 1
  [../]
  [./mc]
    type = TensorMechanicsPlasticTensile
    tensile_strength = ts
    yield_function_tolerance = 1E-6
    tensile_tip_smoother=0
    internal_constraint_tolerance = 1E-5
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
 youngs_modulus = 2e6
    poissons_ratio = 0
  [../]
  [./stress]
    type = ComputeMultiPlasticityStress
    ep_plastic_tolerance = 1E-5
    plastic_models = mc
  [../]
[]


[Executioner]
  end_time = 7
  dt = 0.1
  type = Transient
[]


[Outputs]
  exodus = true
[]#
  
