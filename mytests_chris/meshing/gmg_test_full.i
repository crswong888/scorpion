# This is a potential frame model that could be useful for seeing how
# complex meshes work in MOOSE, but it is currently incomplete.

[Mesh]
  type = FileMesh
  file = gmg_test_full.inp
[]

[Modules/TensorMechanics/LineElementMaster]
  # Identify variables
  add_variables = true
  displacements = 'disp_x disp_y disp_z'
  rotations = 'rot_x rot_y rot_z'

  # Geometry parameters
  area =
  Iy =
  Iz =

  [./element_AB]
    block = elem_AB_EDGE2
    y_orientation = '0.0 0.0 1.0'
  [../]
  [./element_BC]
    block = elem_BC_EDGE2
    y_orientation = '0.0 1.0 0.0'
  [../]
[]

[Materials]
  [./elasticity]
    type = ComputeElasticityBeam
    youngs_modulus =
    poissons_ratio =
    shear_coefficient =
  [../]
  [./stress]
    type = ComputeBeamResultants
  [../]
  [./density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values =
  [../]
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  num_steps = 1
  line_search = none
[]

[Outputs]
  exodus = true
[]
