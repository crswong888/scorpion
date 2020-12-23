[Mesh]
  type = GeneratedMesh
  dim = 1
[]

[Problem]
  solve = false
[]

[Functions]
  # DEFAULT OUTPUT IS CORRECTED ACCELERATION
  [corrected_accel_func]
    type = BaselineCorrection
    data_file = ramp_accel_small_dt.csv
    gamma = 0.5
    beta = 0.25
    accel_fit_order = 1
  []
  # THIS ONE OUTPUTS CORRECTED VELOCITY
  [corrected_vel_func]
    type = BaselineCorrection
    data_file = ramp_accel_small_dt.csv
    series_type = velocity
    gamma = 0.5
    beta = 0.25
    accel_fit_order = 1
  []
  # THIS ONE OUTPUTS CORRECTED DISPLACEMENT
  [corrected_disp_func]
    type = BaselineCorrection
    data_file = ramp_accel_small_dt.csv
    series_type = displacement
    gamma = 0.5
    beta = 0.25
    accel_fit_order = 1
  []
[]

# FOR APPLYING AS BOUNDARY CONDITION - USE FUNCTIONIC AND PRESETACCELERATION

[Executioner]
  type = Transient
  num_steps = 800
  dt = 0.005
[]

[Postprocessors]
  [corrected_accel]
    type = FunctionValuePostprocessor
    function = corrected_accel_func
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [corrected_vel]
    type = FunctionValuePostprocessor
    function = corrected_vel_func
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [corrected_disp]
    type = FunctionValuePostprocessor
    function = corrected_disp_func
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Outputs]
  csv = true
[]
