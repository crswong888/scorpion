# This input file is a test for the deflection of typical Timoshenko Beam using the same BVP
# as loaded_cantilever.i, except with the elastic properties of steel rather than a rigid body.
#
# The theoretical maximum deflection of cantilever beam with a concentrated force at its free end
# is given by (see input properties for variable values):
#
# u = \frac{P * L}{\kappa * G * A} + \frac{P * L^{3}}{3 * E * I} = -0.04923 m

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  rotations = 'rot_x rot_y rot_z'
[]

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 2 #devel
  #nx = 100 # this is a lot, but this is where it finally converges on the theoretical solution
  xmin = 0.0
  xmax = 5.0
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
  [disp_z]
    order = FIRST
    family = LAGRANGE
  []
  [rot_x]
    order = FIRST
    family = LAGRANGE
  []
  [rot_y]
    order = FIRST
    family = LAGRANGE
  []
  [rot_z]
    order = FIRST
    family = LAGRANGE
  []
[]

[Kernels]
  # DISPLACEMENTS
  [stress_x]
    type = StressDivergenceBeam
    component = 0
    variable = disp_x
  []
  [stress_y]
    type = StressDivergenceBeam
    component = 1
    variable = disp_y
  []
  [stress_z]
    type = StressDivergenceBeam
    component = 2
    variable = disp_z
  []

  # ROTATIONS
  [stress_rx]
    type = StressDivergenceBeam
    component = 3
    variable = rot_x
  []
  [stress_ry]
    type = StressDivergenceBeam
    component = 4
    variable = rot_y
  []
  [stress_rz]
    type = StressDivergenceBeam
    component = 5
    variable = rot_z
  []
[]

[Functions]
  [load]
    type = ConstantFunction
    value = -200e+03
  []
[]

[NodalKernels]
  [concentrated]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    boundary = right
    function = load
  []
[]

[Materials]
  [elastic]
    type = ComputeElasticityBeam
    youngs_modulus = 200e+09
    poissons_ratio = 0.3
    shear_coefficient = 0.8497 # $\kappa = frac{10 * (1 + \nu)}{12 + 11 * \nu}$ for rectangles
  []
  [strain]
    type = ComputeIncrementalBeamStrain
    area = 0.01761
    Iy = 0.8616e-03
    Iz = 0.8616e-03
    y_orientation = '0.0 1.0 0.0'
  []
  [stress]
    type = ComputeBeamResultants
    outputs = exodus
    output_properties = 'forces moments'
  []
[]

[BCs]
  # DISPLACEMENTS
  [fixx]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0.0
  []
  [fixy]
    type = DirichletBC
    variable = disp_y
    boundary = left
    value = 0.0
  []
  [fixz]
    type = DirichletBC
    variable = disp_z
    boundary = left
    value = 0.0
  []

  # ROTATIONS
  [fixrx]
    type = DirichletBC
    variable = rot_x
    boundary = left
    value = 0.0
  []
  [fixry]
    type = DirichletBC
    variable = rot_y
    boundary = left
    value = 0.0
  []
  [fixrz]
    type = DirichletBC
    variable = rot_z
    boundary = left
    value = 0.0
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
  num_steps = 1
[]

[Postprocessors]
  [deflection]
    type = NodalMaxValue
    variable = disp_y
    boundary = right
  []
[]

[Outputs]
  exodus = true
  perf_graph = true
[]
