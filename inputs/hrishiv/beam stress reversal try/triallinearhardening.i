[GlobalParams]
  displacements = 'disp_x disp_y  disp_z'
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  xmax = 6
   ymax = 0.3
   zmax = 0.3
   nx = 120
   ny = 6
   nz = 6


[]

[MeshModifiers]
  [./load_point]
   type = AddExtraNodeset
   new_boundary = load_point
   coord = '3 0.3 0.15'
 [../]

[]


[Modules/TensorMechanics/Master]
  [./all]
    strain = FINITE
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    generate_output = 'strain_xx strain_yy strain_zz stress_xx stress_yy stress_zz plastic_strain_xx'# vonmises_stress'
    additional_generate_output = ' max_principal_stress'
  [../]
[]

[AuxVariables]
  [./von_mises]
    #Dependent variable used to visualize the Von Mises stress
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./intnl]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./von_mises_kernel]
    #Calculates the von mises stress and assigns it to von_mises
    type = RankTwoScalarAux
    variable = von_mises
    rank_two_tensor = stress
   # execute_on = timestep_end
    scalar_type = VonMisesStress
  [../]
  [./intnl_auxk]
    type = MaterialStdVectorAux
    property = plastic_internal_parameter
    index = 0
    variable = intnl
  [../]
[]

[Materials]
  [./elastic_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 210e9
    poissons_ratio = 0

  [../]
  [./stress]
    type = ComputeMultiPlasticityStress
    ep_plastic_tolerance = 1e-10
    plastic_models = 'J2'
  [../]
[]
[UserObjects]
  [str]
    type = TensorMechanicsHardeningLinear
   # value = 100e6 0 140e6 0.02 194e6 0.0474 274e6 0.0814 310e6 0.104 # Yield Stress
   value_0 = 100e6
   slope = 1.05e10


  []
  [J2]
    type = TensorMechanicsPlasticJ2
    yield_strength = str
    yield_function_tolerance = 1e3
    internal_constraint_tolerance = 1e-7
    #max_iterations = 4
  []
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
   type = ParsedFunction
   value = -1e6*t
  [../]
[]

[Preconditioning]
  [./SMP]
    type = 'SMP'
    full = TRUE
petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
  petsc_options_value = 'asm lu 1 101'


#petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_atol -snes_rtol -snes_max_it -ksp_atol -ksp_rtol -sub_pc_factor_shift_type'
#  petsc_options_value = 'gmres asm lu 1E-8 1E-8 25 1E-8 1E-8 NONZERO'
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.01
  end_time = 1.75
  nl_max_its = 30
#petsc_options = '-snes_ksp_ew'
 # petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
 # petsc_options_value = 'asm lu 1 101'

  solve_type = 'PJFNK'
#solve_type = Newton
#scheme = explicit-euler


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
[./vonmises_stress]
    type= ElementExtremeValue
    value_type = max
    #variable = vonmises_stress
variable = von_mises
[../]
#[./stress]
#    type= ElementExtremeValue
#    value_type = max
#    variable = stress_yy
#[../]
[./stress]
    type= ElementalVariableValue
     elementid = 2879
    variable = stress_xx
[../]

[./strain1]
    type= ElementalVariableValue
     elementid = 2879
    variable = strain_xx
[../]

#[./strain]
#    type= ElementExtremeValue
#    value_type = max
#    variable = strain_xx
#[../]
[./pstrain]
  type = ElementalVariableValue
  elementid = 2879
  variable = plastic_strain_xx
[../]

[./intnl]
  type = ElementalVariableValue
  elementid = 2879
  variable = intnl
[../]
[]

[Outputs]
  csv = true
  exodus = true
[]