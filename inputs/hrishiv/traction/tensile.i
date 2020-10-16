[GlobalParams]
  displacements = 'disp_x disp_y  disp_z'
[]

[Mesh]
  type = GeneratedMesh
  dim = 3
  xmax = 6
   ymax = 0.3
   zmax = 0.3
   nx = 60
   ny = 4
   nz = 4 

 
[]

[MeshModifiers]
 [./load_point]
   type = AddExtraNodeset
   new_boundary = load_point
  coord = '3 0.15 0.15'
 [../]

[] 


[Modules/TensorMechanics/Master]
  [./all]
    strain = FINITE
    add_variables = true
    displacements = 'disp_x disp_y disp_z'
    generate_output = 'strain_xx strain_yy strain_zz stress_yy stress_zz vonmises_stress'
  [../]
[]

[AuxVariables]
  
  [./stress_xx]
    order = CONSTANT
    family = MONOMIAL
  [../]
 
[]

[AuxKernels]
  
  [./stress_xx]
    type = RankTwoAux
    variable = stress_xx
    rank_two_tensor = stress
    index_i = 0
    index_j = 0
#execute_on = timestep_end
  [../]

  
[]

[Materials]
  [./elastic_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 210e9
    poissons_ratio = 0.3
  [../]
[./tensile]
    type = TensileStressUpdate
    tensile_strength = ts
    smoothing_tol = 0.0
    yield_function_tol = 1.0E-12
  [../]
  [./stress]
    type = ComputeMultipleInelasticStress
    inelastic_models = tensile
    perform_finite_strain_rotations = false
  [../]
    
[]
[UserObjects]
  [./ts]
  
type = TensorMechanicsHardeningConstant
 value = 100e6
[../]
[]
  


[BCs]
    [./pressure1]
    type = Pressure
    variable = disp_x
    boundary = 'right'
    function = 80*t
    factor = 1
    component = 0
  [../]
[./pressure2]
    type = Pressure
    variable = disp_x
    boundary = left
    function = -80*t
    factor = 1
    component = 0
  [../]
[]



[Preconditioning]
  [./SMP]
    type = 'SMP'
    full = TRUE
petsc_options = '-snes_ksp_ew'
 petsc_options_iname = '-pc_type -sub_pc_type -pc_asm_overlap -ksp_gmres_restart'
  petsc_options_value = 'asm lu 1 101'
  

 [../]
[]

[Executioner]
  type = Transient
  dt = 0.01
  end_time = 2.5
  nl_max_its = 30


#solve_type = 'PJFNK'
solve_type = Newton
#scheme = explicit-euler

  
[]

[Postprocessors]
[./vonmises_stress]
    type= ElementExtremeValue
    value_type = max
    variable = vonmises_stress
#variable = von_mises
[../]
[./stress_xx]
    type= PointValue
   point = load_point
    variable = stress_xx
[../]
[./strain_xx]
    type= ElementExtremeValue
    value_type = max
    variable = strain_xx
[../]
[]

[Outputs]
  #csv = true
  exodus = true
[]
