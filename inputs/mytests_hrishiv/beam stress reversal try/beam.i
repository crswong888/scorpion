
[GlobalParams]
  displacements = "disp_x disp_y disp_z"
[]

#[Mesh]
#  type = GeneratedMesh
#  dim = 3
#  xmax = 6
#  ymax = 0.3
#  zmax = 0.3
#  nx = 120
#  ny = 6
#  nz = 6
#[]

[MeshModifiers]
  [./load_point]
    type = AddExtraNodeset
    new_boundary = load_point
    coord = "3 0.3 0.15"
  [../]
[]

[Modules/TensorMechanics/Master]
  [./all]
    strain = FINITE
    add_variables = true
    displacements = "disp_x disp_y disp_z"
    generate_output = "strain_xx strain_yy strain_zz stress_xx stress_yy stress_zz"
  [../]
[]
[Functions]
  [./str]
    type = PiecewiseLinear
    x = '0  100'
    y = '100e6 210e8'
  [../]
[]


[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 210e9
    poissons_ratio = 0
  [../]
#  [./stress]
#    type = ComputeMultiPlasticityStress
#    ep_plastic_tolerance = 1e-10
#    plastic_models = "J2"
#  [../]
  [./isotropic_plasticity]
    type = IsotropicPlasticityStressUpdate
    yield_stress = 100e6
    hardening_function = str
  [../]
  [./radial_return_stress]
    type = ComputeMultipleInelasticStress
    tangent_operator = elastic
    inelastic_models = 'isotropic_plasticity'
  [../]
[]


#[UserObjects]
#  [str]
#    type = TensorMechanicsHardeningExponential
#    value_0 = 100e6
#    value_residual = 200e6
#    rate = 2
#  []
#  [J2]
#    type = TensorMechanicsPlasticJ2
#    yield_strength = str
#    internal_constraint_tolerance = 1e-7
#    []
#[]


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
    variable = disp_x
    boundary = right
    value = 0.0
  [../]
[]

[NodalKernels]
  [./load]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = load_point
    enable = true
  [../]
[]

[Functions]
  [./load]
    type = PiecewiseLinear
    x = "0.0 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5 9.0 9.5 10.0 10.5 11.0 11.5 12"
    y = "0.0 0.5 1.0 0.5 0.0 -0.5 -1 -0.5 0 0.5 1.0 0.5 0.0 -0.5 -1 -0.5 0 0.5 1.0 0.5 0.0 -0.5 -1 -0.5 0"
    scale_factor = -1e6
  [../]
[]


[Preconditioning]
  [./SMP]
    type = SMP
    full = true
    petsc_options = "-snes_ksp_ew"
    petsc_options_iname = "-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart"
    petsc_options_value = "asm lu 1 101"
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.01
  end_time = 12
  nl_max_its = 30
  solve_type = "NEWTON"
[]

[Postprocessors]
  [./disp_y]
    type = NodalMaxValue
    variable = disp_y
    boundary = load_point
  [../]
  [./force_y]
    type = FunctionValuePostprocessor
    function = load
  [../]
  [./stress1]
    type = ElementalVariableValue
    variable = stress_xx
    elementid = 2879
  [../]
  [./stress2]
    type = ElementalVariableValue
    variable = stress_yy
    elementid = 2879
  [../]
  [./stress3]
    type = ElementalVariableValue
    variable = stress_zz
    elementid = 2879
  [../]
  [./strain1]
    type = ElementalVariableValue
    variable = strain_xx
    elementid = 2879
  [../]
  [./strain2]
    type = ElementalVariableValue
    variable = strain_yy
    elementid = 2879
  [../]

  [./strain3]
    type = ElementalVariableValue
    variable = strain_zz
    elementid = 2879
  [../]
[]


[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
