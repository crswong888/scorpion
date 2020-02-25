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

[Executioner]
  type = Steady
[]

[VectorPostprocessors]
  [./readcsv]
    type = CSVReader
    csv_file = testcsv.csv
    force_preic = true
  [../]
[]

[Outputs]
  [./returncsv]
    type = CSV
    execute_on = INITIAL
    execute_postprocessors_on = NONE
  [../]
[]
