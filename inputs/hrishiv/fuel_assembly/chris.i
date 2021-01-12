[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  rotations = 'rot_x rot_y rot_z' # neeeds to be overrided on shell objects
[]

[Mesh]
  type = FileMesh
  file = threerods_rigidbeam.e
  allow_renumbering = false
  partitioner = parmetis
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
  [rot_x]
  []
  [rot_y]
    block = 'controlrod fuelrod s1xyplane s2xyplane dimplehor1 dimplever1 springhor1 springver1
             dimplehor2 dimplever2 springhor2 springver2 rigidbeamhor rigidbeamver
             contact_spring1 contact_spring2'
  []
  [rot_z]
    block = 'controlrod fuelrod s1xzplane s2xzplane dimplehor1 dimplever1 springhor1 springver1
             dimplehor2 dimplever2 springhor2 springver2 rigidbeamhor rigidbeamver contact_spring1
             contact_spring2'
  []
[]

[AuxVariables]
  [vel_x]
  []
  [vel_y]
  []
  [vel_z]
  []
  [accel_x]
  []
  [accel_y]
  []
  [accel_z]
  []
  [rot_vel_x]
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xzplane s1xyplane s2xzplane s2xyplane'
  []
  [rot_vel_y]
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xyplane s2xyplane'
  []
  [rot_vel_z]
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xzplane s2xzplane'
  []
  [rot_accel_x]
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xzplane s1xyplane s2xzplane s2xyplane'
  []
  [rot_accel_y]
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xyplane s2xyplane'
  []
  [rot_accel_z]
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xzplane s2xzplane'
  []
[]

[Kernels]
  [spring_disp_x]
    type = StressDivergenceSpring
    block = 'dimplehor1 dimplever1 springhor1 springver1 dimplehor2 dimplever2 springhor2 springver2
             contact_spring1 contact_spring2'
    component = 0
    variable = disp_x
  []
  [spring_disp_y]
    type = StressDivergenceSpring
    block = 'dimplehor1 dimplever1 springhor1 springver1 dimplehor2 dimplever2 springhor2 springver2
             contact_spring1 contact_spring2'
    component = 1
    variable = disp_y
  []
  [spring_disp_z]
    type = StressDivergenceSpring
    block = 'dimplehor1 dimplever1 springhor1 springver1 dimplehor2 dimplever2 springhor2 springver2
             contact_spring1 contact_spring2'
    component = 2
    variable = disp_z
  []
  [spring_rot_x]
    type = StressDivergenceSpring
    block = 'dimplehor1 dimplever1 springhor1 springver1 dimplehor2 dimplever2 springhor2 springver2
             contact_spring1 contact_spring2'
    component = 3
    variable = rot_x
  []
  [spring_rot_y]
    type = StressDivergenceSpring
    block = 'dimplehor1 dimplever1 springhor1 springver1 dimplehor2 dimplever2 springhor2 springver2
             contact_spring1 contact_spring2'
    component = 4
    variable = rot_y
  []
  [spring_rot_z]
    type = StressDivergenceSpring
    block = 'dimplehor1 dimplever1 springhor1 springver1 dimplehor2 dimplever2 springhor2 springver2
             contact_spring1 contact_spring2'
    component = 5
    variable = rot_z
  []
  [shell_x]
    type = ADStressDivergenceShell
    block = 's1xzplane s1xyplane s2xzplane s2xyplane'
    component = 0
    variable = disp_x
    through_thickness_order = SECOND
  []
  [shell_y]
    type = ADStressDivergenceShell
    block = 's1xzplane s1xyplane s2xzplane s2xyplane'
    component = 1
    variable = disp_y
    through_thickness_order = SECOND
  []
  [shell_z]
    type = ADStressDivergenceShell
    block = 's1xzplane s1xyplane s2xzplane s2xyplane'
    component = 2
    variable = disp_z
    through_thickness_order = SECOND
  []
  [shell_rotx]
    type = ADStressDivergenceShell
    block = 's1xzplane s1xyplane s2xzplane s2xyplane'
    component = 3
    variable = rot_x
    through_thickness_order = SECOND
  []
  [shell_roty]
    type = ADStressDivergenceShell
    block = 's1xyplane s2xyplane'
    component = 4
    variable = rot_y
    through_thickness_order = SECOND
  []
  [shell_rotz]
    type = ADStressDivergenceShell
    block = 's1xzplane s2xzplane'
    component = 4
    variable = rot_z
    through_thickness_order = SECOND
  []
  [rigid_stress_x]
    type = StressDivergenceBeam
    block = 'rigidbeamhor rigidbeamver'
    component = 0
    variable = disp_x
  []
  [rigid_stress_y]
    type = StressDivergenceBeam
    block = 'rigidbeamhor rigidbeamver'
    component = 1
    variable = disp_y
  []
  [rigid_stress_z]
    type = StressDivergenceBeam
    block = 'rigidbeamhor rigidbeamver'
    component = 2
    variable = disp_z
  []
  [rigid_stress_rx]
    type = StressDivergenceBeam
    block = 'rigidbeamhor rigidbeamver'
    component = 3
    variable = rot_x
  []
  [rigid_stress_ry]
    type = StressDivergenceBeam
    block = 'rigidbeamhor rigidbeamver'
    component = 4
    variable = rot_y
  []
  [rigid_stress_rz]
    type = StressDivergenceBeam
    block = 'rigidbeamhor rigidbeamver'
    component = 5
    variable = rot_z
  []
[]

  # Wondering why we are using 'use_displaced_mesh = true' here if small strain
  #
  # [inertial_force_x_xyplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = 's1xyplane s2xyplane'
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
  # []
  # [inertial_force_x_xzplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = 's1xzplane s2xzplane'
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
  # []
  # [inertial_force_y_xyplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = 's1xyplane s2xyplane'
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
  # []
  # [inertial_force_y_xzplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = 's1xzplane s2xzplane'
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
  # []
  # [inertial_force_z_xyplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = 's1xyplane s2xyplane'
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
  # []
  # [inertial_force_z_xzplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = 's1xzplane s2xzplane'
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
  # []
  # [inertial_force_rotx_xyplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = 's1xyplane s2xyplane'
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
  # []
  # [inertial_force_rotx_xzplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = 's1xzplane s2xzplane'
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
  # []
  # [inertial_force_roty_xyplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = 's1xyplane s2xyplane'
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
  # []
  # [inertial_force_rotz_xzplane]
  #   type = ADInertialForceShell
  #   use_displaced_mesh = true
  #   block = 's1xzplane s2xzplane'
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
  # []
# []

[AuxKernels]
  [accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
    execute_on = TIMESTEP_END
  []
  [vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.5
    execute_on = TIMESTEP_END
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.25
    execute_on = TIMESTEP_END
  []
  [vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.5
    execute_on = TIMESTEP_END
  []
  [accel_z]
    type = NewmarkAccelAux
    variable = accel_z
    displacement = disp_z
    velocity = vel_z
    beta = 0.25
    execute_on = TIMESTEP_END
  []
  [vel_z]
    type = NewmarkVelAux
    variable = vel_z
    acceleration = accel_z
    gamma = 0.5
    execute_on = TIMESTEP_END
  []
  [rot_accel_x]
    type = NewmarkAccelAux
    variable = rot_accel_x
    displacement = rot_x
    velocity = rot_vel_x
    beta = 0.25
    execute_on = TIMESTEP_END
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xzplane s1xyplane s2xzplane s2xyplane'
  []
  [rot_vel_x]
    type = NewmarkVelAux
    variable = rot_vel_x
    acceleration = rot_accel_x
    gamma = 0.5
    execute_on = TIMESTEP_END
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xzplane s1xyplane s2xzplane s2xyplane'
  []
  [rot_accel_y]
    type = NewmarkAccelAux
    variable = rot_accel_y
    displacement = rot_y
    velocity = rot_vel_y
    beta = 0.25
    execute_on = TIMESTEP_END
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xyplane s2xyplane'
  []
  [rot_vel_y]
    type = NewmarkVelAux
    variable = rot_vel_y
    acceleration = rot_accel_y
    gamma = 0.5
    execute_on = TIMESTEP_END
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xyplane s2xyplane'
  []
  [rot_accel_z]
    type = NewmarkAccelAux
    variable = rot_accel_z
    displacement = rot_z
    velocity = rot_vel_z
    beta = 0.25
    execute_on = TIMESTEP_END
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xzplane s2xzplane'
  []
  [rot_vel_z]
    type = NewmarkVelAux
    variable = rot_vel_z
    acceleration = rot_accel_z
    gamma = 0.5
    execute_on = TIMESTEP_END
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver s1xzplane s2xzplane'
  []
[]

[Modules/TensorMechanics/LineElementMaster]
    velocities = 'vel_x vel_y vel_z'
    accelerations = 'accel_x accel_y accel_z'
    rotational_velocities = 'rot_vel_x rot_vel_y rot_vel_z'
    rotational_accelerations = 'rot_accel_x rot_accel_y rot_accel_z'

    dynamic_consistent_inertia = true
    beta = 0.25
    gamma = 0.5

    # parameters for 5% Rayleigh damping
    # zeta = 0.0005438894818 # stiffness proportional damping
    # eta = 3.26645357034 # Mass proportional Rayleigh damping

  [block_1] #control rod
    block = 1
    area = 11.244 #od 12.04 id 11.43
    Iy = 193.69
    Iz = 193.69
    y_orientation = '0.0 1.0 0.0'
    density = 6.56e-6 #kg/mm3
  []
  [block_2] #fuel rod
    block = 2
    area = 87.25
    Iy = 605.8
    Iz = 605.8
    y_orientation = '0.0 1.0 0.0'
    density = 9.73e-6 #kg/mm3
  []
[]

[Materials]
  [elasticity_controlrod]
    type = ComputeElasticityBeam
    youngs_modulus = 91000  #N/mm2 or MPa Zircaloy4
    poissons_ratio = 0.33
    block = controlrod
  []
  [elasticity_fuelrod]
    type = ComputeElasticityBeam
    youngs_modulus = 150553  #N/mm2 or MPa Zircaloy4
    poissons_ratio = 0.33
    block = fuelrod
  []
  [stress_beams]
    type = ComputeBeamResultants
    block = 'controlrod fuelrod rigidbeamhor rigidbeamver'
    outputs = exodus
    output_properties = 'forces moments'
  []
  [linear_spring_hor]
    type = LinearSpring
    block = 'dimplehor1 springhor1 dimplehor2 springhor2'
    y_orientation = '1.0 0.0 0.0'
    kx = 126.0
    ky = 126.0
    kz = 126.0
    krx = 126.0
    kry = 126.0
    krz = 126.0
  []
  [linear_spring_ver]
    type = LinearSpring
    block = 'dimplever1 springver1 dimplever2 springver2 contact_spring1 contact_spring2'
    y_orientation = '0.0 0.0 1.0'
    kx = 126.0
    ky = 126.0
    kz = 126.0
    krx = 126.0
    kry = 126.0
    krz = 126.0
  []
  [elasticityshell]
    type = ADComputeIsotropicElasticityTensorShell
    youngs_modulus = 195000
    poissons_ratio = 0.292
    block = 's1xzplane s1xyplane s2xzplane s2xyplane'
    through_thickness_order = SECOND
  []
  [strainshellxyplane]
    type = ADComputeIncrementalShellStrain
    block = 's1xyplane s2xyplane'
    rotations = 'rot_x rot_y'
    thickness = 0.1
    through_thickness_order = SECOND
  []
  [strainshellxzplane]
    type = ADComputeIncrementalShellStrain
    block = 's1xzplane s2xzplane'
    rotations = 'rot_x rot_z'
    thickness = 0.1
    through_thickness_order = SECOND
  []
  [stressshell]
    type = ADComputeShellStress
    block = 's1xzplane s1xyplane s2xzplane s2xyplane'
    through_thickness_order = SECOND
  []
  [densityshell]
    type = GenericConstantMaterial
    block = 's1xzplane s1xyplane s2xzplane s2xyplane'
    prop_names = density
    prop_values = 7.86e-6
  []
  [rigid_strain]
    type = ComputeRigidBeamStrain
    block = 'rigidbeamhor rigidbeamver'
    penalty = 1e+07
  []
[]

[BCs]
  [dis_x]
    type = DirichletBC
    boundary = 'control_left control_right fuel_left fuel_right spring_bottom'
    variable = disp_x
    value = 0.0
  []
  [dis_y]
    type = DirichletBC
    boundary = 'control_left control_right fuel_left fuel_right spring_bottom'
    variable = disp_y
    value = 0.0
  []
  [dis_z]
    type = DirichletBC
    boundary = 'control_left control_right fuel_left fuel_right spring_bottom'
    variable = disp_z
    value = 0.0
  []
  [rot_x]
    type = DirichletBC
    boundary = 'control_left control_right fuel_left fuel_right spacer_grid spring_bottom'
    variable = rot_x
    value = 0.0
  []
  [rot_y]
    type = DirichletBC
    boundary = 'control_left control_right fuel_left fuel_right spacer_grid spring_bottom'
    variable = rot_y
    value = 0.0
  []
  [rot_z]
    type = DirichletBC
    boundary = 'control_left control_right fuel_left fuel_right spacer_grid spring_bottom'
    variable = rot_z
    value = 0.0
  []
[]

[NodalKernels]
  [force_y2]
    type = ConstantRate
    variable = disp_y
    boundary = midpoint
    rate = -100
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
    petsc_options_iname = '-ksp_type -pc_type -sub_pc_type -sub_pc_factor_shift_type'
    petsc_options_value = ' gmres     asm      lu           NONZERO'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  scheme = explicit-euler
  end_time = 2
  dt = 0.005
  l_max_its = 250
  timestep_tolerance = 1e-08 # this is needed so that solver doesn't fail on very last time step
  petsc_options = '-ksp_snes_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'
[]

[Postprocessors]
  [accel_y]
    type = PointValue
    variable = accel_y
    point = '2355.3 0 0'
  []
  [disp_y]
    type = PointValue
    variable = disp_y
    point = '2355.3 0 0'
  []
[]

[Outputs]
  csv = true
  exodus = true
  perf_graph = true
  file_base = completthreerods_out
[]
