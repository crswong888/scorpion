# Computes the axisymmetric stress-strain state of a thick-walled tube subject to internal pressure.

[GlobalParams]
  disp_x = disp_x
  disp_y = disp_y
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 4   # 0.125m/element
  xmin = 1.0   # r_i = 1.0m
  xmax = 1.5   # r_o = 1.5m
  ny = 24  # 0.125m/element
  ymin = 0.0
  ymax = 3.0   # l = 3.0m
[]

[Problem]
  coord_type = RZ
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = true
    generate_output = 'strain_xx strain_yy strain_zz stress_xx stress_yy stress_zz vonmises_stress'
  [../]
[]

[AuxVariables]
  [./axial_stress]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./hoop_stress]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./axial_stress]
    type = RankTwoScalarAux
    rank_two_tensor = stress
    variable = axial_stress
    scalar_type = AxialStress
    execute_on = timestep_end
  [../]
  [./hoop_stress]
    type = RankTwoScalarAux
    rank_two_tensor = stress
    variable = hoop_stress
    scalar_type = HoopStress
    execute_on = timestep_end
  [../]
[]

[Functions]
  [./pressure]
    type = ConstantFunction
    value = 2.5e7   # Constant internal pressure P = 2.5e7Pa
  [../]
[]

[BCs]
  [./Pressure]
    [./internal_pressure]
      boundary = left
      function = pressure
    [../]
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 120.0e9   # representative of aluminium, E = 120.0e9Pa
    poissons_ratio = 0.3
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
  solve_type = NEWTON
  num_steps = 1
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
