### This is a test to ensure the a preic object is executed at all of the
### objects exec times: Once during EXEC_INITIAL, before initial conditions,
### and once per all other exec times, after auxiliary kernels.

[Mesh]
  type = GeneratedMesh
  dim = 1
[]

[Problem]
  solve = false
[]

[Functions]
  [./multiply_t]
    type = ParsedFunction
    value = '2 * t + 1'
  [../]
[]

[Executioner]
  type = Transient
  num_steps = 10
[]

[Postprocessors]
  [./random_pp]
    ## run an arbitrary pp to inspect invocations per time-step
    type = FunctionValuePostprocessor
    function = multiply_t
    execute_on = 'INITIAL TIMESTEP_END'
    force_preic = true
  [../]
[]

[Outputs]
  perf_graph = true
[]
