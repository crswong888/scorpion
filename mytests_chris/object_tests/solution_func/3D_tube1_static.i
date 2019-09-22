# Transforms the axisymmetric solution of a thick-walled tube subject to internal pressure to 3D, XYZ coordinates.

[GlobalParams]
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
    existing_subdomains = '0'
    layers = '0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23'
    new_ids = '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24'
  [../]
  [./rotate]
    type = Transform
    transform = ROTATE
    vector_value = '0 -90 0'
    depends_on = make3D
  [../]
  [./1]
    type = SideSetsBetweenSubdomains
    master_block = 1
    paired_block = 2
    new_boundary = l1
    depends_on = make3D
  [../]
  [./2]
    type = SideSetsBetweenSubdomains
    master_block = 2
    paired_block = 3
    new_boundary = l2
    depends_on = make3D
  [../]
  [./3]
    type = SideSetsBetweenSubdomains
    master_block = 3
    paired_block = 4
    new_boundary = l3
    depends_on = make3D
  [../]
  [./4]
    type = SideSetsBetweenSubdomains
    master_block = 4
    paired_block = 5
    new_boundary = l4
    depends_on = make3D
  [../]
  [./5]
    type = SideSetsBetweenSubdomains
    master_block = 5
    paired_block = 6
    new_boundary = l5
    depends_on = make3D
  [../]
  [./6]
    type = SideSetsBetweenSubdomains
    master_block = 6
    paired_block = 7
    new_boundary = l6
    depends_on = make3D
  [../]
  [./7]
    type = SideSetsBetweenSubdomains
    master_block = 7
    paired_block = 8
    new_boundary = l7
    depends_on = make3D
  [../]
  [./8]
    type = SideSetsBetweenSubdomains
    master_block = 8
    paired_block = 9
    new_boundary = l8
    depends_on = make3D
  [../]
  [./9]
    type = SideSetsBetweenSubdomains
    master_block = 9
    paired_block = 10
    new_boundary = l9
    depends_on = make3D
  [../]
  [./10]
    type = SideSetsBetweenSubdomains
    master_block = 10
    paired_block = 11
    new_boundary = l10
    depends_on = make3D
  [../]
  [./11]
    type = SideSetsBetweenSubdomains
    master_block = 11
    paired_block = 12
    new_boundary = l11
    depends_on = make3D
  [../]
  [./12]
    type = SideSetsBetweenSubdomains
    master_block = 12
    paired_block = 13
    new_boundary = l12
    depends_on = make3D
  [../]
  [./13]
    type = SideSetsBetweenSubdomains
    master_block = 13
    paired_block = 14
    new_boundary = l13
    depends_on = make3D
  [../]
  [./14]
    type = SideSetsBetweenSubdomains
    master_block = 14
    paired_block = 15
    new_boundary = l14
    depends_on = make3D
  [../]
  [./15]
    type = SideSetsBetweenSubdomains
    master_block = 15
    paired_block = 16
    new_boundary = l15
    depends_on = make3D
  [../]
  [./16]
    type = SideSetsBetweenSubdomains
    master_block = 16
    paired_block = 17
    new_boundary = l16
    depends_on = make3D
  [../]
  [./17]
    type = SideSetsBetweenSubdomains
    master_block = 17
    paired_block = 18
    new_boundary = l17
    depends_on = make3D
  [../]
  [./18]
    type = SideSetsBetweenSubdomains
    master_block = 18
    paired_block = 19
    new_boundary = l18
    depends_on = make3D
  [../]
  [./19]
    type = SideSetsBetweenSubdomains
    master_block = 19
    paired_block = 20
    new_boundary = l19
    depends_on = make3D
  [../]
  [./20]
    type = SideSetsBetweenSubdomains
    master_block = 20
    paired_block = 21
    new_boundary = l20
    depends_on = make3D
  [../]
  [./21]
    type = SideSetsBetweenSubdomains
    master_block = 21
    paired_block = 22
    new_boundary = l21
    depends_on = make3D
  [../]
  [./22]
    type = SideSetsBetweenSubdomains
    master_block = 22
    paired_block = 23
    new_boundary = l22
    depends_on = make3D
  [../]
  [./23]
    type = SideSetsBetweenSubdomains
    master_block = 23
    paired_block = 24
    new_boundary = l23
    depends_on = make3D
  [../]
[]

[UserObjects]
  [./soln]
    type = SolutionUserObject
    mesh = RZ_tube1_static_out.e
    system_variables = 'disp_x disp_y'
  [../]
[]

[Functions]
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
    youngs_modulus = 120.0e9
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
  scheme = explicit-euler
  num_steps = 1
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
