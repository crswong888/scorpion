# BVP: A cantilever beam with a concentrated force at its free end.
#
# The maximum deflection should be nearly zero, but the forces and moments should correspond
# to an elastic beam subject to the same BVP (see loaded_cantilever_nominal.i)

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  rotations = 'rot_x rot_y rot_z'
[]

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 2 #devel
  # nx = 100
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
  [rigid]
    type = ComputeRigidBeamStrain
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
