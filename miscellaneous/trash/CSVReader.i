[Mesh]
  type = GeneratedMesh
  xmin = 0
  ymin = 0
  zmin = 0
  xmax = 1
  ymax = 1
  zmax = 1
  nx = 1
  ny = 1
  nz = 1
  dim = 3
[]

[Problem]
  kernel_coverage_check = false
[]

[Variables][dummy][][]

[Functions]
  [./function1]
    type = ParsedFunction
    value = 'pi + sin(t)'
  [../]
  [./function2]
    type = ParsedFunction
    value = 'pi - cos(t)'
  [../]
[]

[Controls]
  [./execute_function2_data]
    type = TimePeriod
    enable_objects = '*/function2_data'
    start_time = 5
  [../]
[]

[Executioner]
  type = Transient
  num_steps = 10
[]

[Postprocessors]
  [./function1_data]
    type = FunctionValuePostprocessor
    function = function1
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./function2_data]
    type = FunctionValuePostprocessor
    function = function2
    execute_on = TIMESTEP_END
  [../]
[]

[VectorPostprocessors]
  [./readcsv]
    type = CSVReader
    csv_file = CSVReader_pp_vals.csv
    execute_on = FINAL
  [../]
[]

[Outputs]
  [./pp_vals]
    type = CSV
    execute_vector_postprocessors_on = NONE
  [../]
  [./vpp_vals]
    type = CSV
    execute_postprocessors_on = NONE
  [../]
[]
