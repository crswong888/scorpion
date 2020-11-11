[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 50
  ny = 10
  nz = 10
  xmax = 0.10
  ymax = 0.01
  zmax = 0.02
  elem_type = HEX20
  displacements = 'disp_x disp_y disp_z'
[]

[Variables]
  [disp_x]
    order = SECOND
    family = LAGRANGE
  []
  [disp_y]
    order = SECOND
    family = LAGRANGE
  []
  [disp_z]
    order = SECOND
    family = LAGRANGE
  []
[]

[Kernels]
  [TensorMechanics]
    displacements = 'disp_x disp_y disp_z'
  []
[]

[AuxVariables]
  [von_mises]
    order = CONSTANT
    family = MONOMIAL
  []
  [nodal_area]
    order = SECOND
    family = LAGRANGE
  []
[]

# [AuxVariables]
#   [von_mises]
#     order = CONSTANT
#     family = MONOMIAL
#   []
# []

[AuxKernels]
  [von_mises_kernel]
    type = RankTwoScalarAux
    variable = von_mises
    rank_two_tensor = stress
    execute_on = timestep_end
    scalar_type = VonMisesStress
  []
[]

# [NodalKernels]
#   [force_y]
#     type = UserForcingFunctionNodalKernel
#     variable = disp_y
#     boundary = right
#     function = force
#   []
# []
#
# [Functions]
#   [force]
#     type = PiecewiseLinear
#     x = '0.0 10.0'
#     y = '0.0 -29.4118' # -10000 N / 340 nodes
#   []
# []

[Functions]
  [point_force]
    type = PiecewiseLinear
    x = '0.0 10.0'
    y = '0.0 -10000.0'
  []
[]

[NodalKernels]
  [point_force_y]
    type = PointForcingFunction3DEquivalent
    variable = disp_y
    function = point_force
    boundary = right
    nodal_area = nodal_area
    total_area_postprocessor = right_area
    enable = true # apply point force=true
  []
[]

[UserObjects]
  [nodal_area]
    type = NodalArea
    variable = nodal_area
    boundary = right
    execute_on = 'INITIAL TIMESTEP_BEGIN'
  []
[]

[BCs]
  [anchor_x]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0.0
  []
  [anchor_y]
    type = DirichletBC
    variable = disp_y
    boundary = left
    value = 0.0
  []
  [anchor_z]
    type = DirichletBC
    variable = disp_z
    boundary = left
    value = 0.0
  []
[]

[Materials]
  active = 'density_steel stress strain elasticity_tensor_steel'
  [elasticity_tensor_steel]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 200e9
    poissons_ratio = 0.3
  []
  [strain]
    type = ComputeSmallStrain
    displacements = 'disp_x disp_y disp_z'
  []
  [stress]
    type = ComputeLinearElasticStress
  []
  [density_steel]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '7800'
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
  solve_type = NEWTON
  nl_rel_tol = 1e-04
  nl_abs_tol = 1e-06
  l_tol = 1e-08
  l_max_its = 250
  dt = 10
  num_steps = 1
  timestep_tolerance = 1e-06
  petsc_options = '-ksp_snes_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'
[]

# [Preconditioning]
#   [SMP]
#     type = SMP
#     full = true
#   []
# []
#
# [Executioner]
#   type = Transient
#   solve_type = PJFNK
#   petsc_options_iname = '-pc_type -pc_hypre_type'
#   petsc_options_value = 'hypre    boomeramg'
#   dt = 1
#   dtmin = 1
#   end_time = 10
# []

[Postprocessors]
  [right_area]
    type = AreaPostprocessor
    boundary = right
    execute_on = 'INITIAL TIMESTEP_BEGIN'
    outputs = none
  []
[]

[Outputs]
  [out]
    type = Exodus
    execute_on = 'initial timestep_end final'
  []
[]
