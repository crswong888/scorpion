[GlobalParams]
  displacements = 'disp_x disp_y  disp_z'
[]

[Mesh]
   file = elmarbeam2.e
[]

[Modules/TensorMechanics/Master]
  [./all]
    strain = FINITE
    add_variables = true
    generate_output = 'strain_xx strain_yy strain_zz stress_xx stress_yy stress_zz vonmises_stress'
  [../]
[]

[Materials]
  [./elastic_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1.92e5
    poissons_ratio = 0.3
  [../]
  [./stress]
    type = ComputeMultiPlasticityStress
    ep_plastic_tolerance = 1e-9
    plastic_models = J2
  [../]
[]


[UserObjects]
  [./str]
    type = TensorMechanicsHardeningConstant
    value = 200 #Yield Stress
  [../]
  [./J2]
    type = TensorMechanicsPlasticJ2
    yield_strength = str
    yield_function_tolerance = 1E-3
    internal_constraint_tolerance = 1E-9
  [../]
[]
 




[BCs]
  [./bottom1]
    type = PresetBC
    variable = disp_y
    boundary = 1
    value = 0.0
  [../]
  [./bottom2]
    type = PresetBC
    variable = disp_z
    boundary = 1
    value = 0.0
  [../]
  [./bottom3]
    type = PresetBC
    variable = disp_x
    boundary = 1
    value = 0.0
  [../]
  [./top]
    type = FunctionPresetBC
    variable = disp_x
    boundary = 2
    function = '0.1*t'
  [../]
[]

[Preconditioning]
  [./SMP]
    type = 'SMP'
    full = TRUE
  [../]
[]

[Executioner]
  type = Transient
  dt = 0.001
  end_time = 1

  solve_type = 'PJFNK'

  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
  petsc_options_value = 'asm lu 1 101'
[]

#[Postprocessors]
#  [./mid_point]
#    type = PointValue
#    variable = disp_x
#    point = '0.5 10 0.5'
#  [../]
#[]

[Outputs]
 # csv = true
  exodus = true
[]


