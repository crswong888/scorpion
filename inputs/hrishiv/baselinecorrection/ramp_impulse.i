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
    time_values = '0 1 2 3 4'
    acceleration_values = '0 981.0 0 -981.0 0'
    gamma = 0.5
    beta = 0.25
    accel_fit_order = 1
    scale_factor = 0.081549439347609 # displacement amplitude approx. 61.312 - this factor targets 5
  []
  # THIS ONE OUTPUTS CORRECTED VELOCITY
  [corrected_vel_func]
    type = BaselineCorrection
    time_values = '0 1 2 3 4'
    acceleration_values = '0 981.0 0 -981.0 0'
    series_type = velocity
    gamma = 0.5
    beta = 0.25
    accel_fit_order = 1
    scale_factor = 0.081549439347609 # displacement amplitude approx. 61.312 - this factor targets 5
  []
  # THIS ONE OUTPUTS CORRECTED DISPLACEMENT
  [corrected_disp_func]
    type = BaselineCorrection
    time_values = '0 1 2 3 4'
    acceleration_values = '0 981.0 0 -981.0 0'
    series_type = displacement
    gamma = 0.5
    beta = 0.25
    accel_fit_order = 1
    scale_factor = 0.081549439347609 # displacement amplitude approx. 61.312 - this factor targets 5
  []
[]

# FOR APPLYING AS BOUNDARY CONDITION - USE FUNCTIONIC AND PRESETACCELERATION

[Executioner]
  type = Transient
  num_steps = 4
  dt = 1
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
