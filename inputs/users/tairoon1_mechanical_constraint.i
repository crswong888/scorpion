[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  [foot_cube]
    type = GeneratedMeshGenerator
    dim = 3
    nx = 10
    ny = 10
    nz = 10
    xmax = 12
    ymax = 12
    zmax = 12
    elem_type = HEX8
  []
  [top_left]
    type = ExtraNodesetGenerator
    new_boundary = 'top_left'
    nodes = '221 223 353 474 595 716 837 958 1079 1200 1321'
    input = foot_cube
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    add_variables = true
    volumetric_locking_correction = true
  []
[]

[Materials]
  [elasticity_steel]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 29000
    poissons_ratio = 0.3
  []
  [stress]
    type = ComputeLinearElasticStress
  []
[]

[BCs]
  [fixx_bot]
    type = DirichletBC
    variable = disp_x
    boundary = bottom
    value = 0
  []
  [fixy_bot]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  []
  [fixz_bot]
    type = DirichletBC
    variable = disp_z
    boundary = bottom
    value = 0
  []
  [fixy_top]
    type = DirichletBC
    variable = disp_y
    boundary = top
    value = 0
  []
  [fixz_top]
    type = DirichletBC
    variable = disp_z
    boundary = top
    value = 0
  []
  [fixy_left]
    type = DirichletBC
    variable = disp_y
    boundary = left
    value = 0
  []
  [fixy_right]
    type = DirichletBC
    variable = disp_y
    boundary = right
    value = 0
  []
  [displace_top_left]
    type = DirichletBC
    variable = disp_x
    boundary = top_left
    value = 0.5
  []
[]

[Constraints]
  [displace_top_right]
    type = EqualValuePlusConstant
    variable = disp_x
    constant = 0.1
    primary = '221 223 353 474 595 716 837 958 1079 1200 1321'
    secondary_node_ids = '240 241 362 483 604 725 846 967 1088 1209 1330'
    penalty = 1e+08
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  nl_rel_tol = 1e-06
  nl_abs_tol = 1e-08
  num_steps = 1
  petsc_options = '-ksp_snes_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'
[]

[Outputs]
  exodus = true
[]
