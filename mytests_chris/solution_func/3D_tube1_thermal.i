# Transforms the axisymmetric solution of a thick-walled tube subject to internal pressure and internal heat to 3D, XYZ coordinates.

[GlobalParams]
  disp_x = disp_x
  disp_y = disp_y
  disp_z = disp_z
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = AnnularMesh
  nt = 32
  rmin = 1.0
  rmax = 1.5
  growth_r = 1
  nr = 4
[]

[MeshModifiers]
  [./make3D]
    type = MeshExtruder
    extrusion_vector = '0 0 3.0'
    num_layers = 24
    bottom_sideset = 'bottom'
    top_sideset = 'top'
  [../]
  [./rotate]
    type = Transform
    transform = ROTATE
    vector_value = '0 -90 0'
    depends_on = make3D
  [../]
[]

[UserObjects]
  [./soln]
    type = SolutionUserObject
    mesh = RZ_tube1_thermal_out.e
    system_variables = 'disp_x disp_y temp'
  [../]
[]

[Functions]
  [./soln_func_temp]
    type = Axisymmetric2D3DSolutionFunction
    solution = soln
    from_variables = 'temp'
  [../]
  [./soln_func_disp_x]
    type = Axisymmetric2D3DSolutionFunction
    solution = soln
    from_variables = 'disp_x disp_y'
    component = 0
  [../]
  [./soln_func_disp_y]
    type = Axisymmetric2D3DSolutionFunction
    solution = soln
    from_variables = 'disp_x disp_y'
    component = 1
  [../]
  [./soln_func_disp_z]
    type = Axisymmetric2D3DSolutionFunction
    solution = soln
    from_variables = 'disp_x disp_y'
    component = 2
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
  [./temp]
  [../]
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
  [./t_soln_aux]
    type = FunctionAux
    variable = temp
    function = soln_func_temp
  [../]
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
  [./x_soln_bc]
    type = FunctionPresetBC
    variable = disp_x
    boundary = 'bottom top rmin rmax'
    function = soln_func_disp_x
  [../]
  [./y_soln_bc]
    type = FunctionPresetBC
    variable = disp_y
    boundary = 'bottom top rmin rmax'
    function = soln_func_disp_y
  [../]
  [./z_soln_bc]
    type = FunctionPresetBC
    variable = disp_z
    boundary = 'bottom top rmin rmax'
    function = soln_func_disp_z
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

