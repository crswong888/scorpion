[GlobalParams]
  displacements= 'disp_x disp_y disp_z'
[]

[Mesh]
   type = GeneratedMesh
   dim = 3
   xmax = 6
   ymax = 0.5
   zmax = 0.5
   nx = 120
   ny = 10
   nz = 10  
[]

[Modules/TensorMechanics/Master]
  [./all]
    strain = FINITE
    add_variables = true
   y_orientation = '0.0 1.0 0.0'
    displacements = 'disp_x disp_y disp_z'
    generate_output = 'stress_xx stress_yy stress_zz vonmises_stress'
  [../]
[]

[Materials]
  [./elastic_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 210e6
    poissons_ratio = 0.3
  [../]
  [./stress]
    type = ComputeFiniteStrainElasticStress
  [../]
[]


[BCs]
  [./fixx1]
    type = DirichletBC
    variable = disp_x
    boundary = 4
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
[./Pressure]
    [./side1]
    boundary = 3
    factor = -8
  [../]
  [../]
[]
 
[Preconditioning]
  [./SMP]
    type = 'SMP'
    full = TRUE
  [../]
[]

[Executioner]
  type = Steady
  solve_type = 'PJFNK'
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
  petsc_options_value = 'asm lu 1 101'
[]



[Outputs]
  exodus = true
[]
