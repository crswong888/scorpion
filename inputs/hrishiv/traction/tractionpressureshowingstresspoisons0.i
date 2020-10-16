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
   coord = '6 0.15 0.15'
  # coord = '0 0.15 0.15'
 [../]

[] 


[Modules/TensorMechanics/Master]
  [./all]
    strain = FINITE
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    generate_output = 'strain_xx strain_yy strain_zz stress_yy stress_zz vonmises_stress'
  [../]
[]

[AuxVariables]
  
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
 
[]

[AuxKernels]
  
  [./stress_xx]
    type = RankTwoAux
    variable = stress_xx
    rank_two_tensor = stress
    index_i = 0
    index_j = 0
#execute_on = timestep_end
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
    output_properties = stress_xx
  [../]
    
[]
[UserObjects]
  [str]
    type = TensorMechanicsHardeningConstant
    value = 80e6 # Yield Stress
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
  [./pressure]
    type = Pressure
    variable = disp_x
    boundary = right
    function = -80e6*t
    factor = 1
    component = 0
  [../]
[]



[Preconditioning]
  [./SMP]
    type = 'SMP'
    full = TRUE
petsc_options = '-snes_ksp_ew'
#  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
#  petsc_options_value = 'asm lu 1 101'
  

petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_atol -snes_rtol -snes_max_it -ksp_atol -ksp_rtol -sub_pc_factor_shift_type'
  petsc_options_value = 'gmres asm lu 1E-8 1E-8 25 1E-8 1E-8 NONZERO'
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.01
  end_time = 2.5
  nl_max_its = 30


#solve_type = 'PJFNK'
solve_type = Newton
#scheme = explicit-euler

  
[]

[Postprocessors]
[./disp_X]
    type = NodalMaxValue
    variable = disp_x
    boundary = load_point
  [../]
[./vonmises]
    type= ElementExtremeValue
    value_type = max
    variable = vonmises_stress
#variable = von_mises
[../]
[./stres]
    type= ElementExtremeValue
    value_type = max
    variable = stress_xx
[../]
#[./stres_p]
 #   type= PointValue
 #   use_displaced_mesh=true
 #   variable = stress_xx
#[../]
[./strain]
    type= ElementExtremeValue
    value_type = max
    variable = strain_xx
[../]
[]

[Outputs]
  #csv = true
  exodus = true
[]
