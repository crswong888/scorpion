# A.K. Chopra, "Dynamics of Structures," Example 5.3 - SDOF system response to half-sine impulse
# By: Christopher Wong, University of New Hampshire

# This input file attempts to replicate the results from Chopra, Example 5.3, using a 
# 25.0 x 1.0 x 1.0 cm cantilever beam with its mass lumped on the unsupported end and the same  
# half-sine impulse defined in the problem.

# The values given in the problem are as follows:
# Mass (m) = 45,594 kg
# Stiffness (k) = 18.0 kN/cm
# Natural Period (T) = 1.0 s
# Damping Ratio (xi) = 0.05
# Impulse (p) = {50*sin(pi*t/0.6)} kN, for all t < 0.6 s

# The properties of the cantilevered beam are as follows:
# Young's modulus (E) = 1.1250e6 kN/cm^2
# Poisson's ratio (v) = 1e-9
# Shear modulus (G) = 5.6250e5 kN/cm^2
# Shear coefficient (k) = 0.83333
# Cross-section area (A) = 1.0 cm^2
# Second moment of area (Iy) = (Iz) = 0.083333 cm^4
# Length (L) = 25.0 cm
# Nodal mass (M) = 0.4559 kN*s^2/cm
# mass proportional rayleigh damping (eta) = 0.6283
# stiffness proportional rayleigh damping (zeta) = 0.0
# HHT time integration parameter (alpha) = 0.0
# Corresponding Newmark beta time integration parameters beta = 0.25 and gamma = 0.5

# For this beam, the dimensionless parameter alpha = kAGL^2/EI = 3.1250e3
# Therefore, the behaves like a Euler-Bernoulli beam.

# The Poisson's ratio was made very small to avoid issues with displacement in the y-direction.
# The eta and zeta parameters were chosen such that the damping ratio xi = 0.05 when T = 1.0 s.
# The elastic modulus was chosen such that the stiffness k = 18.0 kN/cm.

# Values from the first few time steps, as given by Chopra, are as follows:
# time   disp_y      vel_y     accel_y
# 0.0    0.0000     0.0000      0.0000               
# 0.1    0.1213     2.4259     48.5188 
# 0.2    0.6462     8.0714     64.3902
# 0.3    1.7002    13.0093     34.3676
# 0.4    3.0071    13.1280    -31.9927
# 0.5    3.9749     6.2281   -106.0050
# 0.6    3.9530    -6.6657   -151.8716                       
# 0.7    2.6727   -18.9400    -93.6151 
# 0.8    0.5299   -23.9155     -5.8945
# 0.9   -1.6788   -20.2598     79.0081
# 1.0   -3.1783    -9.7299    131.5900

# The results generated from this analysis match closely with those given by Chopra.

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 16
  xmin = 0.0
  xmax = 25.0
[]

[Modules/TensorMechanics/LineElementMaster]
  [./all]
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'

    # Geometry parameters
    area = 1.0
    Iy = 0.08333
    Iz = 0.08333
    y_orientation = '0.0 1.0 0.0'

    # dynamic simulation using consistent mass/inertia matrix
    dynamic_nodal_translational_inertia = True
    boundary = right

    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'

    nodal_mass = 0.4559
    beta = 0.25 # Newmark time integraion parameter
    gamma = 0.5 # Newmark time integraion parameter

    # optional parameters for numerical (alpha) and Rayleigh damping
    alpha = 0.0 # HHT time integration parameter
    eta = 0.6283 # Mass proportional Rayleigh damping
    zeta = 0.0 # Stiffness proportional Rayleigh damping
  [../]
[]

[Functions]
  [./force]
    type = ParsedFunction
    value = 'if(t<0.6, 50*sin(pi*t/0.6), 0*t)'
  [../]
[]

[NodalKernels]
  [./force_y2]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    boundary = right
    function = force
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
  [./fixr1]
    type = DirichletBC
    variable = rot_x
    boundary = left
    value = 0.0
  [../]
  [./fixr2]
    type = DirichletBC
    variable = rot_y
    boundary = left
    value = 0.0
  [../]
  [./fixr3]
    type = DirichletBC
    variable = rot_z
    boundary = left
    value = 0.0
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus = 1.1250e6
    poissons_ratio = 1e-9
    shear_coefficient = 0.8333
  [../]
  [./stress]
    type = ComputeBeamResultants
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
  dt = 0.1
  end_time = 1.0
  timestep_tolerance = 1e-6
[]

[Postprocessors]
  [./disp_y]
    type = PointValue
    point = '25.0 0.0 0.0'
    variable = disp_y
  [../]
  [./vel_y]
    type = PointValue
    point = '25.0 0.0 0.0'
    variable = vel_y
  [../]
  [./accel_y]
    type = PointValue
    point = '25.0 0.0 0.0'
    variable = accel_y
  [../]
  [./force]
    type = FunctionValuePostprocessor
    function = force
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  perf_graph = true
[]
