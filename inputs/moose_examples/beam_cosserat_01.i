# THIS INPUT FILE WAS COPIED FROM THE OFFICIAL MOOSE GITHUB

# Beam bending.  One end is clamped and the other end is subjected to
# a surface traction.
# The joint normal and shear stiffnesses are set very large, so
# that this situation should be identical to the standard (non-Cosserat)
# isotropic elasticity case.
[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 40
  xmax = 10
  ny = 1
  nz = 4
  zmin = -0.5
  zmax = 0.5
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  Cosserat_rotations = 'wc_x wc_y wc_z'
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
  [./wc_x]
  [../]
  [./wc_y]
  [../]
[]

[Kernels]
  [./cx_elastic]
    type = CosseratStressDivergenceTensors
    variable = disp_x
    component = 0
  [../]
  [./cy_elastic]
    type = CosseratStressDivergenceTensors
    variable = disp_y
    component = 1
  [../]
  [./cz_elastic]
    type = CosseratStressDivergenceTensors
    variable = disp_z
    component = 2
  [../]
  [./x_couple]
    type = StressDivergenceTensors
    variable = wc_x
    displacements = 'wc_x wc_y wc_z'
    component = 0
    base_name = couple
  [../]
  [./y_couple]
    type = StressDivergenceTensors
    variable = wc_y
    displacements = 'wc_x wc_y wc_z'
    component = 1
    base_name = couple
  [../]
  [./x_moment]
    type = MomentBalancing
    variable = wc_x
    component = 0
  [../]
  [./y_moment]
    type = MomentBalancing
    variable = wc_y
    component = 1
  [../]
[]

[BCs]
  # zmin is called back
  # zmax is called front
  # ymin is called bottom
  # ymax is called top
  # xmin is called left
  # xmax is called right
  [./no_dispy]
    type = PresetBC
    variable = disp_y
    boundary = 'bottom top'
    value = 0.0
  [../]
  [./no_wc_x]
    type = PresetBC
    variable = wc_x
    boundary = 'bottom top back front left right'
    value = 0.0
  [../]
  [./clamp_z]
    type = PresetBC
    variable = disp_z
    boundary = left
    value = 0.0
  [../]
  [./clamp_x]
    type = PresetBC
    variable = disp_x
    boundary = left
    value = 0.0
  [../]
  [./end_traction]
    type = VectorNeumannBC
    variable = disp_z
    vector_value = '-2E-4 0 0'
    boundary = right
  [../]
[]

[AuxVariables]
  [./wc_z]
  [../]
  [./stress_xx]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./stress_xy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./stress_xz]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./stress_yx]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./stress_yy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./stress_yz]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./stress_zx]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./stress_zy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./stress_zz]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./couple_stress_xx]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./couple_stress_xy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./couple_stress_xz]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./couple_stress_yx]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./couple_stress_yy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./couple_stress_yz]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./couple_stress_zx]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./couple_stress_zy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./couple_stress_zz]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

[AuxKernels]
  [./stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
  [../]
  [./stress_xy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xy
    index_i = 0
    index_j = 1
  [../]
  [./stress_xz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xz
    index_i = 0
    index_j = 2
  [../]
  [./stress_yx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yx
    index_i = 1
    index_j = 0
  [../]
  [./stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
  [../]
  [./stress_yz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yz
    index_i = 1
    index_j = 2
  [../]
  [./stress_zx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zx
    index_i = 2
    index_j = 0
  [../]
  [./stress_zy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zy
    index_i = 2
    index_j = 1
  [../]
  [./stress_zz]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_zz
    index_i = 2
    index_j = 2
  [../]
  [./couple_stress_xx]
    type = RankTwoAux
    rank_two_tensor = couple_stress
    variable = couple_stress_xx
    index_i = 0
    index_j = 0
  [../]
  [./couple_stress_xy]
    type = RankTwoAux
    rank_two_tensor = couple_stress
    variable = couple_stress_xy
    index_i = 0
    index_j = 1
  [../]
  [./couple_stress_xz]
    type = RankTwoAux
    rank_two_tensor = couple_stress
    variable = couple_stress_xz
    index_i = 0
    index_j = 2
  [../]
  [./couple_stress_yx]
    type = RankTwoAux
    rank_two_tensor = couple_stress
    variable = couple_stress_yx
    index_i = 1
    index_j = 0
  [../]
  [./couple_stress_yy]
    type = RankTwoAux
    rank_two_tensor = couple_stress
    variable = couple_stress_yy
    index_i = 1
    index_j = 1
  [../]
  [./couple_stress_yz]
    type = RankTwoAux
    rank_two_tensor = couple_stress
    variable = couple_stress_yz
    index_i = 1
    index_j = 2
  [../]
  [./couple_stress_zx]
    type = RankTwoAux
    rank_two_tensor = couple_stress
    variable = couple_stress_zx
    index_i = 2
    index_j = 0
  [../]
  [./couple_stress_zy]
    type = RankTwoAux
    rank_two_tensor = couple_stress
    variable = couple_stress_zy
    index_i = 2
    index_j = 1
  [../]
  [./couple_stress_zz]
    type = RankTwoAux
    rank_two_tensor = couple_stress
    variable = couple_stress_zz
    index_i = 2
    index_j = 2
  [../]
[]

[VectorPostprocessors]
  [./soln]
    type = LineValueSampler
    sort_by = x
    variable = 'disp_x disp_z stress_xx stress_xz stress_zx stress_zz wc_x wc_y  couple_stress_xx couple_stress_xz couple_stress_zx couple_stress_zz'
    start_point = '0 0 0.5'
    end_point = '10 0 0.5'
    num_points = 11
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeLayeredCosseratElasticityTensor
    young = 1.2
    poisson = 0.3
    layer_thickness = 1
    joint_normal_stiffness = 1E16
    joint_shear_stiffness = 1E16
  [../]
  [./strain]
    type = ComputeCosseratSmallStrain
  [../]
  [./stress]
    type = ComputeCosseratLinearElasticStress
  [../]
[]

[Preconditioning]
  [./andy]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_atol -snes_rtol -snes_max_it -ksp_atol -ksp_rtol -sub_pc_factor_shift_type'
    petsc_options_value = 'gmres asm lu 1E-10 1E-14 10 1E-15 1E-10 NONZERO'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = Newton
  num_steps = 1
[]

[Outputs]
  execute_on = 'timestep_end'
  file_base = beam_cosserat_01
  csv = true
  exodus = true
[]
