[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
[]

[Mesh]
  type = FileMesh
  file = Test-transfer.inp
  displacements = 'disp_x disp_y disp_z'
  construct_side_list_from_node_list = true
[]

[Executioner]
  type = Transient
  solve_type = Newton
  scheme = explicit-euler
  num_steps = 1
  line_search = none
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true

  [./Outputs]
    type = Exodus
  [../]
[]
