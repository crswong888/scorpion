#include "PresetLSBLCAccelerationAction.h"

#include "Conversion.h"
#include "FEProblem.h"
#include "Factory.h"

registerMooseAction("scorpionApp", PresetLSBLCAccelerationAction, "add_vector_postprocessor");

registerMooseAction("scorpionApp", PresetLSBLCAccelerationAction, "add_function");

registerMooseAction("scorpionApp", PresetLSBLCAccelerationAction, "add_postprocessor");

registerMooseAction("scorpionApp", PresetLSBLCAccelerationAction, "add_ic");

registerMooseAction("scorpionApp", PresetLSBLCAccelerationAction, "add_bc");

template <>
InputParameters
validParams<PresetLSBLCAccelerationAction>()
{
  InputParameters params = validParams<Action>();
  params.addRequiredParam<FileName>("csv_file",
      "The name of the CSV file containing the original acceleration time-history data. "
      "The columns must contain those headers which are supplied to the accel_name and "
      "time_name parameters.");
  params.addRequiredParam<std::string>("accel_name", " ");
  params.addRequiredParam<std::string>("time_name", " ");
  params.addParam<Real>("start_time", " ");
  params.addParam<Real>("end_time", " ");
  params.addRequiredParam<unsigned int>("order", " ");
  params.addRequiredParam<Real>("beta", "beta parameter for Newmark time integration.");
  params.addRequiredParam<Real>("gamma", "gamma parameter for Newmark time integration.");
  // other params to be included eventually:
  // outputs?
  params.addClassDescription(
      " ");
  return params;
}

PresetLSBLCAccelerationAction::PresetLSBLCAccelerationAction(const InputParameters & params)
  : Action(params)
{
  // will need to make this work for multiple input accelerations
  // and develop a nice file/object naming system
}

void
PresetLSBLCAccelerationAction::act()
{
  if (_current_task == "add_vector_postprocessor")
  {
    // Invoke CSVReader to write the unadjusted acceleration data to a vpp
    InputParameters csv_params = _factory.getValidParams("CSVReader");
    csv_params.set<FileName>("csv_file") = getParam<FileName>("csv_file");
    csv_params.set<bool>("header") = true;
    csv_params.set<bool>("allow_duplicate_execution_on_initial") = true;

    _problem->addVectorPostprocessor("CSVReader", "accel_data", csv_params);

    // Add the LSBLC vpp
    InputParameters params = _factory.getValidParams("LeastSquaresBaselineCorrection");
    params.applyParameters(parameters());
    params.set<VectorPostprocessorName>("vectorpostprocessor") = {"accel_data"};
    params.set<ExecFlagEnum>("execute_on") = EXEC_INITIAL;
    params.set<bool>("allow_duplicate_execution_on_initial") = true;

    _problem->addVectorPostprocessor(
      "LeastSquaresBaselineCorrection", "BL_adjustments", params);
  }

  else if (_current_task == "add_function")
  {
    InputParameters params = _factory.getValidParams("PiecewiseLinearVPP");
    params.set<VectorPostprocessorName>("vectorpostprocessor") = {"BL_adjustments"};
    params.set<std::string>("argument_column") = {"time"};
    params.set<std::string>("value_column") = {"adjusted_acceleration"};

    _problem->addFunction("PiecewiseLinearVPP", "adj_accel_func", params);
  }

  /*else if (_current_task == "add_postprocessor")
  {
    InputParameters params = _factory.getValidParams("FunctionValuePostprocessor");
    params.set<FunctionName>("function") = {"adj_accel_func"};
    params.set<bool>("allow_duplicate_execution_on_initial") = true;
    params.set<ExecFlagEnum>("execute_on") = EXEC_INITIAL;

    _problem->addPostprocessor(
      "FunctionValuePostprocessor", "initial_accel_value", params);
  }*/
}
