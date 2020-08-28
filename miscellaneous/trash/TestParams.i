[Mesh]
  type = GeneratedMesh
  dim = 1
[]

[Problem]
  solve = false
[]

[UserObjects]
  [test_params]
    type = TestParams
    foo = some_string
    # bar = 8
    baz = '8 8 8'
  []
[]

[Executioner]
  type = Steady
[]
