# This is a 3D rodlet model of irradiated Zr-4 cladding subject to a
# transverse loading of 2500N at its mid span.

# The displacements and material properties are those expected at the typical
# level of radiation for a 2.5-yr LWR run.

# The displacements were the sum total of elastic, thermoelastic, and plastic
# strains. The empty mesh assumes the deformed nodal coordiantes.

# The elastic moduli were computed using the MATPRO material model.

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  file = Quad8_3D_deformed.e  # this creates a blank (0 stress) deformed mesh
                              # of the Quad8 model.
  partitioner = centroid
  centroid_partitioner_direction = y
[../]

[UserObjects]
  [./mat_soln]
    type = SolutionUserObject
    mesh = Quad8_3D_deformed.e
    system_variables = 'poissons_ratio youngs_modulus'
    timestep = LATEST
    execute_on = 'INITIAL'
  [../]
[]

[Functions]
  [./soln_func_poissons_ratio]
    type = Axisymmetric2D3DSolutionFunction
    solution = mat_soln
    from_variables = 'poissons_ratio'
  [../]
  [./soln_func_youngs_modulus]
    type = Axisymmetric2D3DSolutionFunction
    solution = mat_soln
    from_variables = 'youngs_modulus'
  [../]
  [./point_load]
    type = ConstantFunction
    value = 15.6250  # 2500-N/160-nodes = 15.625-N/node (approximate)
  [../]
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = true
  [../]
[]

[NodalKernels]
  [./point_load_x]
    # apply the approximated point force to mid_point boundary in x-direction
    type = UserForcingFunctionNodalKernel
    variable = disp_x
    function = point_load
    boundary = mid_point
  [../]
[]

[AuxVariables]
  ## store elastic moduli element qp variables
  [./poissons_ratio]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./youngs_modulus]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./poissons_ratio]
    type = FunctionAux
    variable = poissons_ratio
    function = soln_func_poissons_ratio
    execute_on = 'INITIAL'
  [../]
  [./youngs_modulus]
    type = FunctionAux
    variable = youngs_modulus
    function = soln_func_youngs_modulus
    execute_on = 'INITIAL'
  [../]
[]

[Materials]
  [./elasticity_tesnors]
    type = VariableElasticModulus
    youngs_modulus = youngs_modulus
    poissons_ratio = poissons_ratio
  [../]
  [./stress]
    type = ComputeLinearElasticStress
  [../]
[]

[BCs]
  [./fixx]
    type = PresetBC
    variable = disp_x
    value = 0
    boundary = 'bottom top'
  [../]
  [./fixy]
    type = PresetBC
    variable = disp_y
    value = 0
    boundary = 'bottom top'
  [../]
  [./fixz]
    type = PresetBC
    variable = disp_z
    value = 0
    boundary = 'bottom top'
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_atol -snes_rtol
                     -snes_max_it -ksp_atol -ksp_rtol -sub_pc_factor_shift_type'
    petsc_options_value = 'gmres asm lu 1E-8 1E-8 25 1E-8 1E-8 NONZERO'
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  scheme = explicit-euler
  num_steps = 1
[]

[Postprocessors]
  [./max_disp_mid]
    type = AverageNodalVariableValue
    variable = disp_x
    boundary = mid_point
  [../]
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
