[Mesh]
  type = FileMesh
  file = chrismodelfinal.e
[]

[Variables]
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
  [../]
  [./rot_x]
  [../]
  [./rot_y]
    block = '1 2 4 6 7 8 9 10 11 12 13 14 15 16 17'
  [../]
  [./rot_z]
    block = '1 2 3 5 7 8 9 10 11 12 13 14 15 16 17'
  [../]
[]

[AuxVariables]
  [./vel_x]
  [../]
  [./vel_y]
  [../]
  [./vel_z]
  [../]
  [./accel_x]
  [../]
  [./accel_y]
  [../]
  [./accel_z]
  [../]
  [./rot_vel_x]
      block = '1 2 3 4 5 6'
  [../]
  [./rot_vel_y]
    block = '1 2 4 6'
  [../]
  [./rot_vel_z]
    block = '1 2 3 5'
  [../]
  [./rot_accel_x]
    block = '1 2 3 4 5 6'
  [../]
  [./rot_accel_y]
      block = '1 2 4 6'
  [../]
  [./rot_accel_z]
    block = '1 2 3 5'
  [../]
[]


[Kernels]
  [./spring_disp_x]
    type = StressDivergenceSpring
    block = '7 8 9 10 11 12 13 14 15 16 17'
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    component = 0
    variable = disp_x
  [../]
  [./spring_disp_y]
    type = StressDivergenceSpring
    block = '7 8 9 10 11 12 13 14 15 16 17'
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    component = 1
    variable = disp_y
  [../]
  [./spring_disp_z]
    type = StressDivergenceSpring
    block = '7 8 9 10 11 12 13 14 15 16 17'
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    component = 2
    variable = disp_z
  [../]
  [./spring_rot_x]
    type = StressDivergenceSpring
    block = '7 8 9 10 11 12 13 14 15 16 17'
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    component = 3
    variable = rot_x
  [../]
  [./spring_rot_y]
    type = StressDivergenceSpring
    block = '7 8 9 10 11 12 13 14 15 16 17'
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    component = 4
    variable = rot_y
  [../]
  [./spring_rot_z]
    type = StressDivergenceSpring
    block = '7 8 9 10 11 12 13 14 15 16 17'
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    component = 5
    variable = rot_z
  [../]
  [./shell_x]
    type = ADStressDivergenceShell
    block = '3 4 5 6'
    component = 0
    variable = disp_x
    through_thickness_order = SECOND
  [../]
  [./shell_y]
    type = ADStressDivergenceShell
    block = '3 4 5 6'
    component = 1
    variable = disp_y
    through_thickness_order = SECOND
  [../]
  [./shell_z]
    type = ADStressDivergenceShell
    block = '3 4 5 6'
    component = 2
    variable = disp_z
    through_thickness_order = SECOND
  [../]
  [./shell_rotx]
    type = ADStressDivergenceShell
    block = '3 4 5 6'
    component = 3
    variable = rot_x
    through_thickness_order = SECOND
  [../]
  [./shell_roty]
    type = ADStressDivergenceShell
    block = '4 6'
    component = 4
    variable = rot_y
    through_thickness_order = SECOND
  [../]
  [./shell_rotz]
    type = ADStressDivergenceShell
    block = '3 5'
    component = 4
    variable = rot_z
    through_thickness_order = SECOND
  [../]
  # [./inertial_force_x_xyplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = '4 6'
  #   displacements = 'disp_x disp_y disp_z'
  #   rotations = 'rot_x rot_y'
  #   velocities = 'vel_x vel_y vel_z'
  #   accelerations = 'accel_x accel_y accel_z'
  #   rotational_velocities = 'rot_vel_x rot_vel_y'
  #   rotational_accelerations = 'rot_accel_x rot_accel_y'
  #   component = 0
  #   variable = disp_x
  #   thickness = 0.1
  #   eta = 0.0
  # [../]
  # [./inertial_force_x_xzplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = '3 5'
  #   displacements = 'disp_x disp_y disp_z'
  #   rotations = 'rot_x rot_z'
  #   velocities = 'vel_x vel_y vel_z'
  #   accelerations = 'accel_x accel_y accel_z'
  #   rotational_velocities = 'rot_vel_x rot_vel_z'
  #   rotational_accelerations = 'rot_accel_x rot_accel_z'
  #   component = 0
  #   variable = disp_x
  #   thickness = 0.1
  #   eta = 0.0
  # [../]
  # [./inertial_force_y_xyplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = '4 6'
  #   displacements = 'disp_x disp_y disp_z'
  #   rotations = 'rot_x rot_y'
  #   velocities = 'vel_x vel_y vel_z'
  #   accelerations = 'accel_x accel_y accel_z'
  #   rotational_velocities = 'rot_vel_x rot_vel_y'
  #   rotational_accelerations = 'rot_accel_x rot_accel_y'
  #   component = 1
  #   variable = disp_y
  #   thickness = 0.1
  #   eta = 0.0
  # [../]
  # [./inertial_force_y_xzplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = '3 5'
  #   displacements = 'disp_x disp_y disp_z'
  #   rotations = 'rot_x rot_z'
  #   velocities = 'vel_x vel_y vel_z'
  #   accelerations = 'accel_x accel_y accel_z'
  #   rotational_velocities = 'rot_vel_x rot_vel_z'
  #   rotational_accelerations = 'rot_accel_x rot_accel_z'
  #   component = 0
  #   variable = disp_y
  #   thickness = 0.1
  #   eta = 0.0
  # [../]
  # [./inertial_force_z_xyplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = '4 6'
  #   displacements = 'disp_x disp_y disp_z'
  #   rotations = 'rot_x rot_y'
  #   velocities = 'vel_x vel_y vel_z'
  #   accelerations = 'accel_x accel_y accel_z'
  #   rotational_velocities = 'rot_vel_x rot_vel_y'
  #   rotational_accelerations = 'rot_accel_x rot_accel_y'
  #   component = 2
  #   variable = disp_z
  #   thickness = 0.1
  #   eta = 0.0
  # [../]
  # [./inertial_force_z_xzplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = '3 5'
  #   displacements = 'disp_x disp_y disp_z'
  #   rotations = 'rot_x rot_z'
  #   velocities = 'vel_x vel_y vel_z'
  #   accelerations = 'accel_x accel_y accel_z'
  #   rotational_velocities = 'rot_vel_x rot_vel_z'
  #   rotational_accelerations = 'rot_accel_x rot_accel_z'
  #   component = 2
  #   variable = disp_z
  #   thickness = 0.1
  #   eta = 0.0
  # [../]
  # [./inertial_force_rotx_xyplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = '4 6'
  #   displacements = 'disp_x disp_y disp_z'
  #   rotations = 'rot_x rot_y'
  #   velocities = 'vel_x vel_y vel_z'
  #   accelerations = 'accel_x accel_y accel_z'
  #   rotational_velocities = 'rot_vel_x rot_vel_y'
  #   rotational_accelerations = 'rot_accel_x rot_accel_y'
  #   component = 3
  #   variable = rot_x
  #   thickness = 0.1
  #   eta = 0.0
  # [../]
  # [./inertial_force_rotx_xzplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = '3 5'
  #   displacements = 'disp_x disp_y disp_z'
  #   rotations = 'rot_x rot_z'
  #   velocities = 'vel_x vel_y vel_z'
  #   accelerations = 'accel_x accel_y accel_z'
  #   rotational_velocities = 'rot_vel_x rot_vel_z'
  #   rotational_accelerations = 'rot_accel_x rot_accel_z'
  #   component = 3
  #   variable = rot_x
  #   thickness = 0.1
  #   eta = 0.0
  # [../]
  # [./inertial_force_roty_xyplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = '4 6'
  #   displacements = 'disp_x disp_y disp_z'
  #   rotations = 'rot_x rot_y'
  #   velocities = 'vel_x vel_y vel_z'
  #   accelerations = 'accel_x accel_y accel_z'
  #   rotational_velocities = 'rot_vel_x rot_vel_y'
  #   rotational_accelerations = 'rot_accel_x rot_accel_y'
  #   component = 4
  #   variable = rot_y
  #   thickness = 0.1
  #   eta = 0.0
  # [../]
  # [./inertial_force_rotz_xzplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = '3 5'
  #   displacements = 'disp_x disp_y disp_z'
  #   rotations = 'rot_x rot_z'
  #   velocities = 'vel_x vel_y vel_z'
  #   accelerations = 'accel_x accel_y accel_z'
  #   rotational_velocities = 'rot_vel_x rot_vel_z'
  #   rotational_accelerations = 'rot_accel_x rot_accel_z'
  #   component = 4
  #   variable = rot_z
  #   thickness = 0.1
  #   eta = 0.0
  # [../]

[]

[AuxKernels]
  [./accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
    execute_on = 'timestep_end'
  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.5
    execute_on = 'timestep_end'
  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.25
    execute_on = 'timestep_end'
  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.5
    execute_on = 'timestep_end'
  [../]
  [./accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    beta = 0.25
    execute_on = 'timestep_end'
  [../]
  [./vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    gamma = 0.5
    execute_on = 'timestep_end'
  [../]
  [./rot_accel_x]
    type = NewmarkAccelAux
    variable = rot_accel_x
    displacement = rot_x
    velocity = rot_vel_x
    beta = 0.25
    execute_on = 'timestep_end'
    block = '1 2 3 4 5 6'
  [../]
  [./rot_vel_x]
    type = NewmarkVelAux
    variable = rot_vel_x
    acceleration = rot_accel_x
    gamma = 0.5
    execute_on = 'timestep_end'
    block = '1 2 3 4 5 6'
  [../]
  [./rot_accel_y]
    type = NewmarkAccelAux
    variable = rot_accel_y
    displacement = rot_y
    velocity = rot_vel_y
    beta = 0.25
    execute_on = 'timestep_end'
    block = '1 2 4 6'
  [../]
  [./rot_vel_y]
    type = NewmarkVelAux
    variable = rot_vel_y
    acceleration = rot_accel_y
    gamma = 0.5
    execute_on = 'timestep_end'
    block = '1 2 4 6'
  [../]
  [./rot_accel_z]
    type = NewmarkAccelAux
    variable = rot_accel_z
    displacement = rot_z
    velocity = rot_vel_z
    beta = 0.25
    execute_on = 'timestep_end'
    block = '1 2 3 5'
  [../]
  [./rot_vel_z]
    type = NewmarkVelAux
    variable = rot_vel_z
    acceleration = rot_accel_z
    gamma = 0.5
    execute_on = 'timestep_end'
    block = '1 2 3 5'
  [../]
[]

[Modules/TensorMechanics/LineElementMaster]
#    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'

    # dynamic simulation using consistent mass/inertia matrix
     dynamic_consistent_inertia = true

    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'
    strain_type = SMALL

    beta = 0.25 # Newmark time integration parameter
    gamma = 0.5 # Newmark time integration parameter

    # parameters for 5% Rayleigh damping
    # zeta = 0.0005438894818 # stiffness proportional damping
    # eta = 3.26645357034 # Mass proportional Rayleigh damping
  [./block_1] #control rod
    block = 1
    area = 11.244 #od 12.04 id 11.43
    Iy = 193.69
    Iz = 193.69
    y_orientation = '0.0 1.0 0.0'
    density = 6.56e-6 #kg/mm3
  [../]
  [./block_2] #fuel rod
    block = 2
    area = 87.25
    Iy = 605.8
    Iz = 605.8
    y_orientation = '0.0 1.0 0.0'
    density = 9.73e-6 #kg/mm3
  [../]

[]

[Materials]
  [./elasticity_controlrod]
    type = ComputeElasticityBeam
    youngs_modulus = 91000  #N/mm2 or MPa Zircaloy4
    poissons_ratio = 0.33
    block = '1'
  [../]
  [./elasticity_fuelrod]
    type = ComputeElasticityBeam
    youngs_modulus = 150553  #N/mm2 or MPa Zircaloy4
    poissons_ratio = 0.33
    block = '2'
  [../]
  [./stress_beams]
    type = ComputeBeamResultants
    block = '1 2'
  [../]
  [./linear_spring_hor]
    type = LinearSpring
    block = '7 9 11 13 15'
    y_orientation = '1.0 0.0 0.0'
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    kx = 126.0
    ky = 126.0
    kz = 126.0
    krx = 126.0
    kry = 126.0
    krz = 126.0
  [../]
  [./linear_spring_ver]
    type = LinearSpring
    block = '8 10 12 14 16 17'
    y_orientation = '0.0 0.0 1.0'
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y rot_z'
    kx = 126.0
    ky = 126.0
    kz = 126.0
    krx = 126.0
    kry = 126.0
    krz = 126.0
  [../]
  [./elasticityshell]
    type = ADComputeIsotropicElasticityTensorShell
    youngs_modulus = 195000
    poissons_ratio = 0.292
    block = '3 4 5 6'
    through_thickness_order = SECOND
  [../]
  [./strainshellxyplane]
    type = ADComputeIncrementalShellStrain
    block = '4 6'
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_y'
    thickness = 0.1
    through_thickness_order = SECOND
  [../]
  [./strainshellxzplane]
    type = ADComputeIncrementalShellStrain
    block = '3 5'
    displacements = 'disp_x disp_y disp_z'
    rotations = 'rot_x rot_z'
    thickness = 0.1
    through_thickness_order = SECOND
  [../]
  [./stressshell]
    type = ADComputeShellStress
    block = '3 4 5 6'
    through_thickness_order = SECOND
  [../]
  [./densityshell]
    type = GenericConstantMaterial
    block = '3 4 5 6'
    prop_names = 'density'
    prop_values = '7.86e-6'
  [../]
[]

[BCs]
  [./dis_x]
    type = DirichletBC
    boundary = '100 101 102 104'
    variable = disp_x
    value = 0.0
  [../]
  [./dis_y]
    type = DirichletBC
    boundary = '100 101 102 104'
    variable = disp_y
    value = 0.0
  [../]
  [./dis_z]
    type = DirichletBC
    boundary = '100  101 102 104'
    variable = disp_z
    value = 0.0
  [../]
  [./rot_x]
    type = DirichletBC
    boundary = '100  101 102 103 104'
    variable = rot_x
    value = 0.0
  [../]
  [./rot_y]
    type = DirichletBC
    boundary = '100  101 102 103 104'
    variable = rot_y
    value = 0.0
  [../]
  [./rot_z]
    type = DirichletBC
    boundary = '100  101 102 103 104'
    variable = rot_z
    value = 0.0
  [../]
[]

[NodalKernels]
  [./force_y2]
    type = ConstantRate
    variable = disp_y
    boundary = '106'
    rate = -100
  [../]
[]

# [Functions]
#   [./accel_y]
#     type = PiecewiseLinear
#     data_file = 'accel_y.csv'
#     format = 'columns'
#     scale_factor = 9810
#   [../]
# []

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = '201                hypre    boomeramg      4'
  end_time = 2.5
  dt = 0.005
  dtmin = 0.001
  nl_abs_tol = 1e-5
    nl_rel_tol = 1e-05
  l_tol = 1e-5
  l_max_its = 20
  nl_max_its = 75
  timestep_tolerance = 1e-8
  # automatic_scaling = true
[]

[Postprocessors]
  [./accel_y]
    type = PointValue
    variable = accel_y
    point = '2355.3 0 0'
  [../]
  [./disp_y]
    type = PointValue
    variable = disp_y
    point = '2355.3 0 0'
  [../]
[]





[Outputs]
  csv = true
  exodus = true
  file_base = completthreerods

[]

# [Debug]
#   show_var_residual_norms = true
#   []
