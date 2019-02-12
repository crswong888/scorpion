# Computes the axisymmetric stress-strain state of a thick-walled tube subject to internal pressure and internal heat.

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

[Functions]
  [./pressure]
    type = ConstantFunction
    value = 2.5e7   # Constant internal pressure P = 2.5e7Pa
  [../]
[]

[Variables]
  [./temp]
  [../]
[]

[Kernels]
  [./heat]
    type = HeatConduction
    variable = temp
  [../]
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = true
    eigenstrain_names = thermal_expansion
    generate_output = 'strain_xx strain_yy strain_zz stress_xx stress_yy stress_zz vonmises_stress hydrostatic_stress'
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

[BCs]
  [./temp_inner]
    type = PresetBC
    variable = temp
    boundary = left
    value = 973.2   # Constant inner temp T_i = 973.2K ~ 700C
  [../]
  [./temp_outter]
    type = PresetBC
    variable = temp
    boundary = right
    value = 293.2   # Constnat outer temp T_o = 293.2K ~ 20C
  [../]
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
    youngs_modulus = 120.0e9   # representative of pure aluminium, E = 120.0e9Pa
    poissons_ratio = 0.3
  [../]
  [./stress]
    type = ComputeLinearElasticStress
  [../]
  [./thermal_properties]
    type = HeatConductionMaterial
    thermal_conductivity = 236.0   # avg. conductivity of pure aluminium from 300K to 600K, K_avg = 236.0W/(m*K)
    specific_heat = 903.0   # pure aluminium, c = 903.0J/(kg*K)
    temp = 293.2   # T_0 = 293.2K ~ 20C, or room temp.
  [../]
  [./thermal_expansion]
    type = ComputeThermalExpansionEigenstrain
    thermal_expansion_coeff = 23.0e-6   # pure aluminum, alpha = 23.6K^-1
    stress_free_temperature = 293.2   # T_0 = 293.2K ~ 20C, or room temp.
    temperature = temp
    eigenstrain_name = thermal_expansion
  [../]
  [./density]
    type = Density
    density = 2702.0   # pure aluminium, rho = 2702.0kg/m^3
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
  start_time = 0.0
  dt = 1.0
  end_time = 1.0
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
