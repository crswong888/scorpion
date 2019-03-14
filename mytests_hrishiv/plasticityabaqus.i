[GlobalParams]
  displacements = 'disp_x disp_y  disp_z'
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  xmax = 12
   ymax = 0.5
   zmax = 0.5
   nx = 60
   ny = 6
   nz = 6  
[]

[MeshModifiers]
  [./load_point]
   type = AddExtraNodeset
   new_boundary = load_point
   coord = '6 0.25 0.5'
 [../]
[] 


[Modules/TensorMechanics/Master]
  [./all]
    strain = FINITE
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    generate_output = 'strain_xx strain_yy strain_zz stress_xx stress_yy stress_zz vonmises_stress'
  [../]
[]

[Materials]
  [./elastic_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 210e9 #210GPa 
    poissons_ratio = 0.25
  [../]
  [./stress]
    type = ComputeMultiPlasticityStress
    ep_plastic_tolerance = 1e-9
    plastic_models = 'J2'
  [../]
[]
[UserObjects]
  [str]
    type = TensorMechanicsHardeningConstant
    value = 350e6 # Yield Stress
  []
  [J2]
    type = TensorMechanicsPlasticJ2
    yield_strength = str
    yield_function_tolerance = 1
    internal_constraint_tolerance = 1
    max_iterations = 4
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
   value = -50e6*t
  [../]
[]

[Preconditioning]
  [./SMP]
    type = 'SMP'
    full = TRUE
petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
  petsc_options_value = 'asm lu 1 101'
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.01
  end_time = 2.5
  nl_max_its = 30

  solve_type = 'PJFNK'

  
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
#[./vonmises_stress]
 #   type = NodalMaxValue
  #  variable = vomises_stress
   # boundary = load_point
  #[../]

[]

[Outputs]
 # csv = true
  exodus = true
[]
