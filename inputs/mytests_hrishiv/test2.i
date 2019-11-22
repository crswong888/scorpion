# Case 1: Cladding only length of 10 pellets (128.8-mm)
# Tests Case 1 - Static loading using a 1D line element mesh

# Material properties are of unirradiated, in-tact Zr-4 cladding.

# Fastest with single processor

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 10
  xmin = 0.0
  xmax = 10
[]

[MeshModifiers]
  [./mid_point]
    type = AddExtraNodeset
    coord = '5'
    new_boundary = mid_point
  [../]
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'

    # Geometry parameters
    area = 0.01
    Iy = 0.0004
    Iz = 0.0004
    y_orientation = '0.0 1.0 0.0'
  [../]
[]

#[Kernels]
#  [./gravity]
 #   type = Gravity
  #  variable = disp_y
   # value = -9.810
    #enable = false # gravity? ... I don't think it works well with LineElementMaster
  #[../]
#[]

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
    value = -1
  [../]
[]

[BCs]
  [./fixx1]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0.0
  [../]
  [./fixy1]
    type = DirichletBC
    variable = disp_y
    boundary = left
    value = 0.0
  [../]
  [./fixz1]
    type = DirichletBC
    variable = disp_z
    boundary = left
    value = 0.0
  [../]
  [./fixrx1]
    type = DirichletBC
    variable = rot_x
    boundary = left
    value = 0.0
  [../]
  [./fixry1]
    type = DirichletBC
    variable = rot_y
    boundary = left
    value = 0.0
  [../]
  [./fixrz1]
    type = DirichletBC
    variable = rot_z
    boundary = left
    value = 0.0
  [../]
  [./fixx2]
    type = DirichletBC
    variable = disp_x
    boundary = right
    value = 0.0
  [../]
  [./fixy2]
    type = DirichletBC
    variable = disp_y
    boundary = right
    value = 0.0
  [../]
  [./fixz2]
    type = DirichletBC
    variable = disp_z
    boundary = right
    value = 0.0
  [../]
  [./fixrx2]
    type = DirichletBC
    variable = rot_x
    boundary = right
    value = 0.0
  [../]
  [./fixry2]
    type = DirichletBC
    variable = rot_y
    boundary = right
    value = 0.0
  [../]
  [./fixrz2]
    type = DirichletBC
    variable = rot_z
    boundary = right
    value = 0.0
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 1E4
    poissons_ratio = 1
    shear_coefficient = 1
  [../]
  [./stress]
    type = ComputeBeamResultants
    outputs = exodus
    output_properties = 'forces moments'
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  #  petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -snes_atol -snes_rtol -snes_max_it -ksp_atol -ksp_rtol -sub_pc_factor_shift_type'
   # petsc_options_value = 'gmres asm lu 1E-8 1E-8 25 1E-8 1E-8 NONZERO'
  [../]
[]

[Executioner]
  type = Steady
  solve_type = Newton
  #num_steps = 1
[]

[Postprocessors]
  [./disp_y]
    type = NodalMaxValue
    variable = disp_y
    boundary = mid_point
  [../]
  [./force_y]
    type = FunctionValuePostprocessor
    function = load
  [../]
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
[]
