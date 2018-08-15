[Mesh]
  type = ConcentricCircleMesh
  num_sectors = 6
  radii = '0.2546 0.3368 0.3600 0.3818 0.3923 0.4025 0.4110 0.4750'
  rings = '10 6 4 4 4 2 2 6 10'
  inner_mesh_fraction = 0.6
  has_outer_square = on
  pitch = 1.42063
  #portion = left_half
  preserve_volumes = off
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
  nl_max_its = 15
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-8
  start_time = 0.0
  dt = 1.0
  end_time = 1.0
[]

[Outputs]
  exodus = true
[]
