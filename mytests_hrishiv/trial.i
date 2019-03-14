[GlobalParams]
  displacements = 'disp_x disp_y  disp_z'
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  xmax = 6
   ymax = 0.3
   zmax = 0.3
   nx = 60
   ny = 4
   nz = 4 

 
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
    generate_output = 'strain_xx strain_yy strain_zz stress_xx stress_yy stress_zz vonmises_stress'
    additional_generate_output = ' max_principal_stress'
  [../]
[]

[Materials]
  [./elastic_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 210e9
    poissons_ratio = 0.3
  [../]
  [./stress]
    type = ComputeMultiPlasticityStress
    ep_plastic_tolerance = 1e-10
    plastic_models = 'J2'
  [../]
[]
[UserObjects]
  [str]
    type = TensorMechanicsHardeningConstant
    value = 100e6 # Yield Stress
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
   value = 1e6*t
  [../]
[]

[Preconditioning]
  [./SMP]
    type = 'SMP'
    full = TRUE
petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_atol -snes_rtol -snes_max_it -ksp_atol -ksp_rtol -sub_pc_factor_shift_type'
  petsc_options_value = 'gmres asm lu 1E-8 1E-8 25 1E-8 1E-8 NONZERO'
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.01
  end_time = 2.5
  nl_max_its = 30

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
    variable = vonmises_stress
[../]
[./stress_xx]
    type= ElementExtremeValue
    value_type = max
    variable = stress_xx
execute_on = timestep_end
[../]
[./strain_xx]
    type= ElementExtremeValue
    value_type = max
    variable = strain_xx
[../]
[]

[Outputs]
  csv = true
  exodus = true
[]
