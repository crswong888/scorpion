#include "PresetLSBLCAccelerationAction.h"

#include "Conversion.h"
#include "FEProblem.h"
#include "Factory.h"

registerMooseAction("scorpionApp", PresetLSBLCAccelerationAction, "add_vector_postprocessor");

registerMooseAction("scorpionApp", PresetLSBLCAccelerationAction, "add_postprocessor");

registerMooseAction("scorpionApp", PresetLSBLCAccelerationAction, "add_ic");

registerMooseAction("scorpionApp", PresetLSBLCAccelerationAction, "add_function");

registerMooseAction("scorpionApp", PresetLSBLCAccelerationAction, "add_bc");

template <>
InputParameters
validParams<PresetLSBLCAccelerationAction>()
{
  InputParameters params = validParams<Action>();
  params.addRequiredParam<VariableName>("variable",
      "The name of the variable that this boundary condition applied to");
  params.addParam<std::vector<VariableName>>("displacements", "The displacements");
  params.addRequiredParam<VariableName>("velocity", "The velocity variable.");
  params.addRequiredParam<VariableName>("acceleration", "The acceleration variable.");
  params.addRequiredParam<std::vector<BoundaryName>>("boundary",
      "The list of boundary IDs from the mesh where this boundary condition applies");
  params.addRequiredParam<FileName>("csv_file",
      "The name of the CSV file containing the original acceleration time-history data - the "
      "columns must contain those headers which are supplied to the acceleration_name and "
      "time_name parameters");
  params.addRequiredParam<std::string>("acceleration_name", "The acceleration column header");
  params.addRequiredParam<std::string>("time_name", "The time column header");
  params.addRequiredRangeCheckedParam<unsigned int>("order", "order < 10",
      "The order of the polynomial fit(s) used to adjust the nominal time histories (coefficients "
      "of higher order polynomials can be difficult to compute and the method generally becomes "
      "unstable when order >= 10)");
  params.addRequiredParam<Real>("gamma", "The gamma parameter for Newmark time integration.");
  params.addRequiredParam<Real>("beta", "The beta parameter for Newmark time integration.");
  params.addParam<bool>("fit_acceleration", true,
      "If set to \"true\", the acceleration time history will be adjusted using a polynomial fit "
      "of the acceleration data");
  params.addParam<bool>("fit_velocity", false,
      "If set to \"true\", the acceleration time history will be adjusted using a polynomial fit "
      "of the velocity data obtained by integration");
  params.addParam<bool>("fit_displacement", false,
      "If set to \"true\", the acceleration time history will be adjusted using a polynomial fit "
      "of the displacement data obtained by double-integration");
  params.addParam<bool>("output_unadjusted", false,
      "If set to \"true\", the nominal time histories computed from Newmark integration alone "
      "will be output along with the baseline corrected time histories");
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
    csv_params.set<bool>("force_preic") = true;

    _problem->addVectorPostprocessor("CSVReader", "accel_data", csv_params);

    // Add the LSBLC vpp
    InputParameters params = _factory.getValidParams("LeastSquaresBaselineCorrection");
    params.applyParameters(parameters());
    params.set<VectorPostprocessorName>("vectorpostprocessor") = {"accel_data"};
    params.set<ExecFlagEnum>("execute_on") = EXEC_INITIAL;
    params.set<bool>("allow_duplicate_execution_on_initial") = true;
    params.set<bool>("force_preic") = true;

    _problem->addVectorPostprocessor("LeastSquaresBaselineCorrection", "BL_adjustments", params);
  }

  else if (_current_task == "add_postprocessor")
  {
    InputParameters params = _factory.getValidParams("VectorPostprocessorComponent");
    params.set<VectorPostprocessorName>("vectorpostprocessor") = {"BL_adjustments"};
    params.set<std::string>("vector_name") = {"adjusted_acceleration"};
    params.set<unsigned int>("index") = 0;
    params.set<ExecFlagEnum>("execute_on") = EXEC_INITIAL;
    params.set<bool>("allow_duplicate_execution_on_initial") = true;
    params.set<bool>("force_preic") = true;

    _problem->addPostprocessor("VectorPostprocessorComponent", "initial_accel_value", params);
  }

  else if (_current_task == "add_ic")
  {
    InputParameters params = _factory.getValidParams("PostprocessorIC");
    params.applyParameters(parameters());
    params.set<VariableName>("variable") = getParam<VariableName>("acceleration");
    params.set<PostprocessorName>("postprocessor") = {"initial_accel_value"};

    _problem->addInitialCondition("PostprocessorIC", "initial_accel", params);
  }

  else if (_current_task == "add_function")
  {
    InputParameters params = _factory.getValidParams("VectorPostprocessorFunction");
    params.set<VectorPostprocessorName>("vectorpostprocessor_name") = {"BL_adjustments"};
    params.set<std::string>("argument_column") = {"time"};
    params.set<std::string>("value_column") = {"adjusted_acceleration"};

    _problem->addFunction("VectorPostprocessorFunction", "adj_accel_func", params);
  }

  else if (_current_task == "add_bc")
  {
    InputParameters params = _factory.getValidParams("PresetAcceleration");
    params.set<std::vector<VariableName>>("velocity") = {getParam<VariableName>("velocity")};
    params.set<std::vector<VariableName>>("acceleration") = {getParam<VariableName>("acceleration")};
    params.applyParameters(parameters());
    params.set<FunctionName>("function") = {"adj_accel_func"};

    _problem->addBoundaryCondition("PresetAcceleration", "induce_acceleration", params);
  }
}
