[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  #nz = 1
  elem_type = QUAD4
  displacements = 'disp_x disp_y'
[]

[Variables]
  [disp_x]
    order = FIRST
    family = LAGRANGE
  []
  [disp_y]
    order = FIRST
    family = LAGRANGE
  []
  [c]
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxVariables]
  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [strain_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [creep_strain_xx]
    order = CONSTANT
    family = MONOMIAL
  []
  [eigen_strain]
    order = CONSTANT
    family = MONOMIAL
  []
  [stress]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [TensorMechanics]
    displacements = 'disp_x disp_y'
    strain = FINITE
  []
  [diff]
    type = Diffusion
    variable = c
  []
  [euler]
    type = TimeDerivative
    variable = c
  []
[]

[AuxKernels]
  [stress_xx]
    type = RankTwoAux
    variable = stress_xx
    rank_two_tensor = stress
    index_j = 0
    index_i = 0
    execute_on = timestep_end
  []
  [strain_xx]
    type = RankTwoAux
    variable = strain_xx
    rank_two_tensor = total_strain
    index_j = 0
    index_i = 0
    execute_on = timestep_end
  []
  [creep_strain_xx]
    type = RankTwoAux
    variable = creep_strain_xx
    rank_two_tensor = creep_strain
    index_j = 0
    index_i = 0
    execute_on = timestep_end
  []
  [eigen_strain]
    type = RankTwoAux
    variable = eigen_strain
    rank_two_tensor = eigenstrain
    index_j = 0
    index_i = 0
  []
[]

[BCs]
  [symmy]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0
  []
  [symmx]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []
  [axial_load]
    type = NeumannBC
    variable = disp_x
    boundary = right
    value    = 10
  []
   [left_c]
    type = DirichletBC
    variable = c
    boundary = 'left'
    value = 0
  []
  [right_c]
    type = DirichletBC
    variable = c
    boundary = 'right'
    value = 1
  []
[]

[Materials]
  [maxwell]
    type = GeneralizedMaxwellModel
    creep_modulus = '10e6 10e6'
    creep_viscosity = '1 10'
    poisson_ratio = 0.4
    young_modulus = 10e6
  []
  [stress]
    type = ComputeMultipleInelasticStress
    inelastic_models = 'creep'
  []
    [var_dependence]
    type = DerivativeParsedMaterial
    block = 0
    function = 0.5*c^2
    args = c
    outputs = exodus
    output_properties = 'var_dep'
    f_name = var_dep
    enable_jit = true
    derivative_order = 2
  []
  [eigenstrain]
    type = ComputeVariableEigenstrain
    block = 0
    eigen_base = '1 1 1 0 0 0'
    prefactor = var_dep
    args = c
    eigenstrain_name = eigenstrain
  []
  [creep]
    type = LinearViscoelasticStressUpdate
  []
  [strain]
    type = ComputeFiniteStrain
    displacements = 'disp_x disp_y'
  []
[]

[UserObjects]
  [update]
    type = LinearViscoelasticityManager
    viscoelastic_model = maxwell
  []
[]

[Postprocessors]
  [stress_xx]
    type = ElementAverageValue
    variable = stress_xx
    block = 'ANY_BLOCK_ID 0'
  []
  [strain_xx]
    type = ElementAverageValue
    variable = strain_xx
    block = 'ANY_BLOCK_ID 0'
  []
  [creep_strain_xx]
    type = ElementAverageValue
    variable = creep_strain_xx
    block = 'ANY_BLOCK_ID 0'
  []
  [c]
    type = ElementIntegralVariablePostprocessor
    variable = c
  []
 [disp]
    type = ElementIntegralVariablePostprocessor
    variable = disp_x
	[]
[eigenstrain]
    type = ElementIntegralVariablePostprocessor
    variable = eigen_strain
[]
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -sub_pc_factor_shift_type'
    petsc_options_value = ' gmres     asm      lu           NONZERO'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  scheme = explicit-euler

  petsc_options = '-ksp_snes_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'

  l_max_its  = 250

  dtmin = 5e-5
  end_time = 100
  timestep_tolerance = 1e-08
  [TimeStepper]
    type = LogConstantDT
    first_dt = 0.1
    log_dt = 0.1
  []

[]

[Outputs]
  file_base = Mvf_out
  exodus = true
  csv = true
[]
