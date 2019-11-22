[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  file = Quad8_3D_annular.inp
  allow_renumbering = false
  construct_side_list_from_node_list = true
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = true
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 9.93E4
    poissons_ratio = 0.318
  [../]
  [./stress]
    type = ComputeLinearElasticStress
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_atol -snes_rtol -snes_max_it -ksp_atol -ksp_rtol -sub_pc_factor_shift_type'
    petsc_options_value = 'gmres asm lu 1E-8 1E-8 25 1E-8 1E-8 NONZERO'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = Newton
  scheme = explicit-euler
  num_steps = 1
  line_search = none
[]

[Outputs]
  exodus = true
[]
