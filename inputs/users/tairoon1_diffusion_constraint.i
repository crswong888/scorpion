[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
[]

[Variables]
  [u]
  []
[]

[Kernels]
  [diff]
    type = Diffusion
    variable = u
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = u
    boundary = left
    value = 0
  []
[]

[Constraints]
  [right]
    type = EqualValuePlusConstant
    variable = u
    constant = 1
    primary = '0 3 23 34 45 56 67 78 89 100 111'
    secondary_node_ids = '20 21 32 43 54 65 76 87 98 109 120'
    penalty = 1e+06
  []
[]

[Executioner]
  type = Steady
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type'
  petsc_options_value = 'hypre boomeramg'
[]

[Outputs]
  exodus = true
[]
