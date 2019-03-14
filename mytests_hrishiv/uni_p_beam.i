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
    displacements = 'disp_x disp_y disp_z'
    generate_output = 'strain_xx strain_yy strain_zz stress_xx stress_yy stress_zz vonmises_stress'
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
# [./strain]
 #   type = ComputeFiniteStrain
  #[../]
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
 # [./fixrx1]
  #  type = DirichletBC
  #  variable = rot_x
 #   boundary = left
 #   value = 0.0
 # [../]
 # [./fixry1]
 #   type = DirichletBC
  #  variable = rot_y
   # boundary = left
    #value = 0.0
  #[../]
  #[./fixrz1]
   # type = DirichletBC
    #variable = rot_z
   # boundary = left
   # value = 0.0
  #[../]
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
  #[./fixrx2]
   # type = DirichletBC
    #variable = rot_x
    #boundary = right
    #value = 0.0
  #[../]
  #[./fixry2]
    #type = DirichletBC
    #variable = rot_y
    #boundary = right
    #value = 0.0
  #[../]
  #[./fixrz2]
   # type = DirichletBC
   # variable = rot_z
   # boundary = right
   # value = 0.0
  #[../]
[./Pressure]
    [./side1]
    variable = disp_x
    boundary = 3
    factor = 8e4
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
#  dt = 0.5
  #end_time = 1
  #nl_max_its = 10

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
