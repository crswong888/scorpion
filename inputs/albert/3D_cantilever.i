# Steady-state analysis of a cantilever beam using 3D element
# The beam is made of Aluminum.
# Young's Modulus = 73.1 GPa
# Poisson's Ratio =  0.33
# Beam Dimensions = 1*0.1*0.1 m^3
# Load = 5000N at free end


[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 10
  ny = 5
  nz = 5
  xmin = 0
  xmax = 1
  ymin = 0
  ymax = 0.1
  zmin = 0
  zmax = 0.1
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
  [disp_z]
  []
[]


[Modules/TensorMechanics/Master]
  [all]
    strain = SMALL
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    # rotations = 'rot_x rot_y rot_z'
    generate_output = 'stress_xx strain_xx stress_yy strain_yy stress_zz strain_zz stress_xy strain_xy stress_xz strain_xz stress_yz strain_yz vonmises_stress'
  []
[]


[NodalKernels]
  [force_y2]
    type = UserForcingFunctionNodalKernel
    function = 1250
    variable = disp_y
    boundary = right
  []
[]


[Materials]
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    poissons_ratio = 0.33
    youngs_modulus = 7.310e10
  []
  [stress]
    type = ComputeLinearElasticStress
   []
[]

[BCs]
  [fixx1]
    type = DirichletBC
    variable = disp_x
    boundary = 'left'
    value = 0
  []
  [fixy1]
    type = DirichletBC
    variable = disp_y
    boundary = 'left'
    value = 0
  []
  [fixz1]
    type = DirichletBC
    variable = disp_z
    boundary = 'left'
    value = 0
  []
  # [pressure]
  #   type = Pressure
  #   boundary = top
  #   variable = disp_y
  #   component = 1
  #   factor = 5000
  # []
  # [disp_y]
  #   type = DirichletBC
  #   variable = disp_y
  #   boundary = 'right'
  #   value = 2.73598e-9
  # []
[]

[Preconditioning]
  [./smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  nl_rel_tol = 1e-04
  nl_abs_tol = 1e-06
  l_tol = 1e-08
  l_max_its = 250
  num_steps = 1
  timestep_tolerance = 1e-06
  petsc_options = '-ksp_snes_ew'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = ' 201                hypre    boomeramg      4'
[]

[Postprocessors]
  [disp_y]
    type = NodalMaxValue
    boundary = 'right'
    variable = disp_y
  []
  [stress_xx]
    type = ElementExtremeValue
    # point = '0 0 0'
    variable = stress_xx

  []
  [stress_yy]
    type = PointValue
    point = '0 0 0'
    variable = stress_yy
  []
  [stress_zz]
    type = PointValue
    point = '0 0 0'
    variable = stress_zz
  []
  [stress_xy]
    type = PointValue
    point = '0 0.05 0.05'
    variable = stress_xy
  []
  [stress_xz]
    type = PointValue
    point = '0 0.05 0.05'
    variable = stress_xz
  []
  [stress_yz]
    type = PointValue
    point = '0 0 0'
    variable = stress_yz
  []
  [strain_xx]
    type = PointValue
    point = '0 0 0'
    variable = strain_xx
  []
  [strain_yy]
    type = PointValue
    point = '0 0 0'
    variable = strain_yy
  []
  [strain_zz]
    type = PointValue
    point = '0 0 0'
    variable = strain_zz
  []
  [strain_xy]
    type = PointValue
    point = '0 0 0'
    variable = strain_xy
  []
  [strain_xz]
    type = PointValue
    point = '0 0 0'
    variable = strain_xz
  []
  [strain_yz]
    type = PointValue
    point = '0 0 0'
    variable = strain_yz
  []
  [mises]
    type = PointValue
    point = '0 0 0'
    variable = vonmises_stress
  []
[]

[Outputs]
  csv = true
  exodus = true
  perf_graph = true
[]
