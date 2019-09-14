[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = AnnularMesh
  nt = 32
  rmax = 5.36
  rmin = 4.76
  growth_r = 1
  nr = 3
  partitioner = parmetis
[]

[MeshModifiers]
  [./make3D]
    type = MeshExtruder
    extrusion_vector = '0 0 128.8'
    num_layers = 30
    bottom_sideset = 'left'
    top_sideset = 'right'
    existing_subdomains = '0'
    layers = '14 15'
    new_ids = '15 16'
  [../]
  [./mid_point]
    type = SideSetsBetweenSubdomains
    master_block = 15
    paired_block = 16
    new_boundary = mid_point
    depends_on = make3D
  [../]
  [./fix_nodes_left]
    type = BoundingBoxNodeSet
    new_boundary = 'left_center'
    top_right = '5.36 0.01 0'
    bottom_left = '-5.36 0 0'
    depends_on = make3D
  [../]
  [./fix_nodes_right]
    type = BoundingBoxNodeSet
    new_boundary = 'right_center'
    top_right = '5.36 0.01 128.8'
    bottom_left = '-5.36 0 128.8'
    depends_on = make3D
  [../]
  [./rotate1]
    type = Transform
    transform = ROTATE
    vector_value = '0 90 0'
    depends_on = make3D
  [../]
  [./rotate2]
    type = Transform
    transform = ROTATE
    vector_value = '90 0 0'
    depends_on = rotate1
  [../]
[]

[Modules/TensorMechanics/Master]
  [./all]
    add_variables = true
  [../]
[]

[Kernels]
  [./gravity]
    type = Gravity
    variable = disp_y
    value = -9810
    enable = false # gravity=true
  [../]
[]

[NodalKernels]
  [./force_y]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = load
    boundary = mid_point
    enable = true # apply_force=true
  [../]
[]

[Functions]
  [./load]
    type = ConstantFunction
    value = -19.5313 # total_load/no_nodes=2500N/128node=19.5313N/node
  [../]
[]

[BCs]
  [./fixx]
    type = PenaltyFlexuralBC
    variable = disp_x
    axis_origin = '0 0 0'
    axis_direction = '0 0 1'
    transverse_direction = '0 1 0'
    component = 0
    penalty = 1.0e+08
    boundary = 'left right'
  [../]
  [./fixy]
    type = PenaltyFlexuralBC
    variable = disp_y
    axis_origin = '0 0 0'
    axis_direction = '0 0 1'
    transverse_direction = '0 1 0'
    component = 1
    penalty = 1.0e+08
    boundary = 'left right'
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 9.93E4
    poissons_ratio = 0.37
  [../]
  [./stress]
    type = ComputeLinearElasticStress
    #outputs = exodus
    #output_properties = stress
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 6.0e-09 # Approximate density of Zr-4
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  num_steps = 1
  petsc_options = '-ksp_snes_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type'
  petsc_options_value = ' 201                hypre    boomeramg'
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
