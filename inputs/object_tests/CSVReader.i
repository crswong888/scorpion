[Mesh]
  type = GeneratedMesh
  dim = 1
[]

[Problem]
  solve = false
[]

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
  [../]
[]
