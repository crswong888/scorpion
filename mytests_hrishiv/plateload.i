[Problem]
  coord_type = RZ
[]

[GlobalParams]
  displacements= 'disp_r disp_z'
[]

[Mesh]
 type = GeneratedMesh
 dim = 2
 xmax = 0.2
 nx = 20
 ymax = 0.2
 ny = 20 
[]



[Modules/TensorMechanics/Master]
  [./all]
   add_variables = true
   strain = small
   displacements = 'disp_r disp_z'
   generate_output = 'stress_zz vonmises_stress'
  [../]
[]



[BCs]
  [./left]
    type = PresetBC
    variable = disp_r
    boundary = left
    value = 0.0
  [../]
  [./right]
    type = Pressure
    variable = disp_r
    boundary = right
    component = 0
    factor = 1e6
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 200e9 #200 GPa
    poissons_ratio = 0.3
    shear_coefficient = 1
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    outputs = exodus
     [../]
[]


[Preconditioning]
  [./smp]
    type = SMP
    full = true
  #  petsc_options = '-snes_ksp_ew'
  #petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
  #petsc_options_value = 'asm lu 1 101'
  [../]
[]

[Executioner]
  type = Steady
  solve_type = Newton
 # petsc_options = '-snes_ksp_ew'
 # petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
 # petsc_options_value = 'asm lu 1 101'
[]




[Outputs]
  exodus = true
  perf_graph = true
[]
 

#[Postprocessors]
#  [./disp_y]
#    type = NodalMaxValue
#    variable = disp_y
#    boundary = mid_point
#  [../]
#  [./force_y]
#    type = FunctionValuePostprocessor
#    function = load
#  [../]
#[]
   




