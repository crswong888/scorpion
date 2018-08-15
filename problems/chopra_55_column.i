# A.K. Chopra, "Dynamics of Structures," Example 5.5 - SDOF system response to half-sine impulse
# with elastoplastic restoring force behavior
# By: Christopher Wong, University of New Hampshire

# This input file attempts to replicate the results from Chopra, Example 5.5, using a distributed
# mass 1.0 x 25.0 x 1.0 cm column with the same half-sine impulse defined in the problem.

# The impulse is applied as a uniform pressure in the y-direction to the top surface of the
# column. Since the cross-section is 1.0 x 1.0 cm, the impulse is equivalent to a pressure
# distributed over a unit surface.

# The column is fixed at the bottom and allowed to displace in only the y-direction at the top.

# This analysis uses Newton-Raphson iterations for non-linear time-steps.

# The values given in the problem are as follows:
# Mass = 45,594 kg (irrelevant for a mdof system)
# Stiffness (k) = 18.0 kN/cm
# Natural Period (T) = 1.0 s
# Damping Ratio (xi) = 0.05
# Impulse (p) = {50*sin(pi*t/0.6)} kN, for all t < 0.6 s
# Yield deformation (u_y) = 2.0 cm
# Yield force (f_y) = 36.0 kN
# Residual force tolerance (epsilon_r) = 10e-3

# The properties of the column are as follows:
# Young's modulus (E) = 450.0 kN/cm^2
# Poisson's ratio (v) = 1.0e-9
# Cross-section area (A) = 1.0 cm^2
# Length (L) = 25.0 cm
# density (rho) = 0.05471 kN*s^2/cm^4
# mass proportional rayleigh damping (eta) = 0.6283
# stiffness proportional rayleigh damping (zeta) = 0.0
# Newmark beta time integration parameters (beta) = 0.25 and (gamma) = 0.5
# Uniform pressure impulse (P) = {50*sin(pi*t/0.6)} kN/cm^2, for all t < 0.6 s
# Tensile Strength (f_y) = 36.0 kN/cm^2

# The Poisson's ratio was made very small to avoid issues with displacement in the y-direction.
# The eta and zeta parameters were chosen such that the damping ratio xi = 0.05 when T = 1.0 s.
# The density was chosen such that the natural period T = 1.0 s.
# The elastic modulus was chosen such that the stiffness k = 18.0 kN/cm.

# Values from the first few time steps, as given by Chopra, are as follows:
# time   disp_y      vel_y    accel_y       f_s
# 0.0    0.0000     0.0000     0.0000    0.0000               
# 0.1    0.1213     2.4259    48.5187    2.1833
# 0.2    0.6462     8.0714    64.3899   11.6309
# 0.3    1.7002    13.0092    34.3673   30.6034
# 0.4    3.1034    15.0553     6.5534   36.0000
# 0.5    4.5434    13.7448   -32.7628   36.0000
# 0.6    5.6262     7.9102   -83.9283   36.0000                    
# 0.7    6.0103    -0.2269   -78.8151   36.0000
# 0.8    5.6409    -7.1614   -59.8736   29.3505
# 0.9    4.7224   -11.2085   -21.0693   12.8176
# 1.0    3.6062   -11.1151    22.9376   -7.2737

# The results generated from this analysis match closely with those given by Chopra.

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 1
  ny = 1
  nz = 1
  xmin = 0.0
  xmax = 1.0
  ymin = 0.0
  ymax = 25.0
  zmin = 0.0
  zmax = 1.0
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
[]

[AuxVariables]
  [./vel_x]
  [../]
  [./accel_x]
  [../]
  [./vel_y]
  [../]
  [./accel_y]
  [../]
  [./vel_z]
  [../]
  [./accel_z]
  [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Kernels]
  [./DynamicTensorMechanics]
    displacements = 'disp_x disp_y disp_z'
    zeta = 0.0
  [../]
  [./inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.25
    gamma = 0.5
    eta= 0.0
  [../]
  [./inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.25
    gamma = 0.5
    eta= 0.6283
  [../]
  [./inertia_z]
    type = InertialForce
    variable = disp_z
    velocity = vel_z
    acceleration = accel_z
    beta = 0.25
    gamma = 0.5
    eta = 0.0
  [../]
[]

[AuxKernels]
  [./accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.5
    execute_on = timestep_end
  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.5
    execute_on = timestep_end
  [../]
  [./accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    beta = 0.25
    execute_on = timestep_end
  [../]
  [./vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    gamma = 0.5
    execute_on = timestep_end
  [../]
  [./stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
  [../]
[]

[Functions]
  [./pressure]
    type = ParsedFunction
    value = 'if(t<0.6, -50*sin(pi*t/0.6), 0*t)'
  [../]
[]

[BCs]
  [./bottom_x]
    type = DirichletBC
    variable = disp_x
    boundary = bottom
    value = 0.0
  [../]
  [./bottom_y]
    type = DirichletBC
    variable = disp_y
    boundary = bottom
    value = 0.0
  [../]
  [./bottom_z]
    type = DirichletBC
    variable = disp_z
    boundary = bottom
    value = 0.0
  [../]
  [./top_x]
    type = DirichletBC
    variable = disp_x
    boundary = top
    value = 0.0
  [../]
  [./top_z]
    type = DirichletBC
    variable = disp_z
    boundary = top
    value = 0.0
  [../]
  [./Pressure]
    [./top_y]
      boundary = top
      function = pressure
      displacements = 'disp_x disp_y disp_z'
      factor = 1.0
    [../]
  [../]
[]

[UserObjects]
  [./strength]
    type = TensorMechanicsHardeningConstant
    value = 36.0
  [../]
  [./plastic]
    type = TensorMechanicsPlasticTensileMulti
    tensile_strength = strength
    yield_function_tolerance = 1.0e-9
    internal_constraint_tolerance = 1.0e-9
    use_custom_returnMap = False
    use_custom_cto = False
    max_iterations = 20
  [../]
[]

[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 450.0
    poissons_ratio = 1.0e-9
  [../]
  [./strain]
    type = ComputeIncrementalSmallStrain
    displacements = 'disp_x disp_y disp_z'
  [../]
  [./stress]
    type = ComputeMultiPlasticityStress
    ep_plastic_tolerance = 1.0e-3
    plastic_models = plastic
    store_stress_old = True
    perform_finite_strain_rotations = False
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 0.05471
  [../]
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  line_search = 'none'
  l_tol = 1e-8
  nl_max_its = 15
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
  start_time = 0.0
  dt = 0.01
  end_time = 10.0
  timestep_tolerance = 1e-6
[]

[Postprocessors]
  [./disp_y]
    type = NodalMaxValue
    variable = disp_y
    boundary = top
  [../]
  [./vel_y]
    type = NodalMaxValue
    variable = vel_y
    boundary = top
  [../]
  [./accel_y]
    type = NodalMaxValue
    variable = accel_y
    boundary = top
  [../]
  [./pressure]
    type = FunctionValuePostprocessor
    function = pressure
  [../]
  [./stress_yy]
    type = ElementAverageValue
    variable = stress_yy
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  print_perf_log = true
[]
