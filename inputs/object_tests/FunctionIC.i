[Mesh]
  type = GeneratedMesh
  dim = 3
  nx = 1
  xmax = 1
  ny = 1
  ymax = 1
  nz = 1
  zmax = 1
[]

[Problem]
  kernel_coverage_check = false
[]

[Variables][dummy][][]

[AuxVariables][testvar][][]

[Functions]
  [test_func]
    type = PiecewiseLinear
    data_file = testcsv.csv
    format = columns
  []
[]

[ICs]
  [test_ic]
    type = FunctionIC
    variable = testvar
    function = test_func
    boundary = bottom
  []
[]

[Executioner]
  type = Transient
  num_steps = 5
[]

[Postprocessors]
  [check_func_value]
    type = FunctionValuePostprocessor
    function = test_func
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [check_var_value]
    type = NodalMaxValue
    variable = testvar
    boundary = bottom
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Outputs]
  exodus = true
[]
