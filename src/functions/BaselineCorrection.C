// SCORPION includes
#include "BaselineCorrection.h"
#include "BaselineCorrectionUtils.h"

// MOOSE includes
#include "DelimitedFileReader.h"

registerMooseObject("scorpionApp", BaselineCorrection);

InputParameters
BaselineCorrection::validParams()
{
  InputParameters params = Function::validParams();

  params.addParam<FileName>("data_file",
      "The name of a CSV file containing raw acceleration time history data.");
  params.addParam<std::string>("time_name",
      "The header name of the column which contains the time values in the data file. If not "
      "specified, they are assumed to be in the first column index.");
  params.addParam<std::string>("acceleration_name",
      "The header name for the column which contains the acceleration values in the data file. If "
      "not specified, they are assumed to be in the second column index.");
  params.addParam<std::vector<Real>>("time_values", "The time abscissa values.");
  params.addParam<std::vector<Real>>("acceleration_values", "The acceleration ordinate values.");

  params.addRequiredParam<Real>("gamma", "The gamma parameter for Newmark time integration.");
  params.addRequiredParam<Real>("beta", "The beta parameter for Newmark time integration.");

  params.addParam<bool>("fit_acceleration", true,
      "If set to \"true\", the acceleration time history will be adjusted using a polynomial fit "
      "of the acceleration data.");
  params.addParam<bool>("fit_velocity", false,
      "If set to \"true\", the acceleration time history will be adjusted using a polynomial fit "
      "of the velocity data obtained by integration.");
  params.addParam<bool>("fit_displacement", false,
      "If set to \"true\", the acceleration time history will be adjusted using a polynomial fit "
      "of the displacement data obtained by double-integration.");
  params.addRequiredRangeCheckedParam<unsigned int>("order", "(0 < order) & (order < 10)",
      "The order of the polynomial fit(s) used to adjust the nominal time histories (coefficients "
      "of higher order polynomials can be difficult to compute and the method generally becomes "
      "unstable when order >= 10).");

  params.addParam<Real>("scale_factor", 1.0,
      "A scale factor to be applied to the adjusted acceleration time history.");
  params.declareControllable("scale_factor");

  return params;
}

BaselineCorrection::BaselineCorrection(const InputParameters & parameters)
  : Function(parameters),
    _gamma(getParam<Real>("gamma")),
    _beta(getParam<Real>("beta")),
    _fit_accel(getParam<bool>("fit_acceleration")),
    _fit_vel(getParam<bool>("fit_velocity")),
    _fit_disp(getParam<bool>("fit_displacement")),
    _order(getParam<unsigned int>("order")),
    _scale_factor(getParam<Real>("scale_factor"))
{
  // determine data source and check parameter consistency
  if (isParamValid("data_file") && !isParamValid("time_values") &&
      !isParamValid("acceleration_values"))
    buildFromFile();
  else if (!isParamValid("data_file") && isParamValid("time_values") &&
           isParamValid("acceleration_values"))
    buildFromXandY();
  else
    mooseError("In BaselineCorrection ",
               _name,
               ": Either `data_file` or `time_values` and `acceleration_values` must be specified "
               "exclusively.");

  // size checks
  if (_time.size() != _accel.size())
    mooseError("In BaselineCorrection ",
               _name,
               ": The length of time and acceleration data must be equal.");
  if (_time.size() == 0 || _accel.size() == 0)
    mooseError("In BaselineCorrection ",
               _name,
               ": The length of time and acceleration data must be > 0.");

  // ensure that at least one best-fit will be created
  if (!_fit_accel && !_fit_vel && !_fit_disp)
    mooseWarning("Warning in " + name() +
                 ". Computation of a polynomial fit is set to \"false\" for all three "
                 "kinematic variables. No adjustments will occur and the output will be the "
                 "raw acceleration time history.");

  // apply baseline correction to raw acceleration time history
  applyCorrection();

  // try building a linear interpolation object
  try
  {
    _linear_interp = libmesh_make_unique<LinearInterpolation>(_time, _adj_accel);
  }
  catch (std::domain_error & e)
  {
    mooseError("In BaselineCorrection ", _name, ": ", e.what());
  }
}

Real
BaselineCorrection::value(Real t, const Point & /*P*/) const
{
  return _scale_factor * _linear_interp->sample(t);
}

void
BaselineCorrection::applyCorrection()
{
  // store a reference to final array index
  unsigned int index_end = _accel.size() - 1;

  // Compute unadjusted velocity and displacment time histories
  Real dt;
  std::vector<Real> vel, disp;
  vel.push_back(0); disp.push_back(0);
  for (unsigned int i = 0; i < index_end; ++i)
  {
    dt = _time[i+1] - _time[i];

    vel.push_back(BaselineCorrectionUtils::newmarkGammaIntegrate(
        _accel[i], _accel[i+1], vel[i], _gamma, dt));
    disp.push_back(BaselineCorrectionUtils::newmarkBetaIntegrate(
        _accel[i], _accel[i+1], vel[i], disp[i], _beta, dt));
  }

  // initialize polyfits and adjusted time history arrays as the nominal ones
  DenseVector<Real> coeffs;
  _adj_accel = _accel;
  std::vector<Real> p_fit, adj_vel = vel, adj_disp = disp;

  // adjust time histories with acceleration fit if desired
  if (_fit_accel)
  {
    coeffs = BaselineCorrectionUtils::getAccelerationFitCoeffs(
      _order, _adj_accel, _time, index_end, _gamma);

    for (unsigned int i = 0; i <= index_end; ++i)
    {
      p_fit = BaselineCorrectionUtils::computePolynomials(_order, coeffs, _time[i]);
      _adj_accel[i] -= p_fit[0];
      adj_vel[i] -= p_fit[1];
      adj_disp[i] -= p_fit[2];
    }
  }

  // adjust with velocity fit
  if (_fit_vel)
  {
    coeffs = BaselineCorrectionUtils::getVelocityFitCoeffs(
      _order, _adj_accel, adj_vel, _time, index_end, _beta);

    for (unsigned int i = 0; i <= index_end; ++i)
    {
      p_fit = BaselineCorrectionUtils::computePolynomials(_order, coeffs, _time[i]);
      _adj_accel[i] -= p_fit[0];
      adj_disp[i] -= p_fit[2];
    }
  }

  // adjust with displacement fit
  if (_fit_disp)
  {
    coeffs = BaselineCorrectionUtils::getDisplacementFitCoeffs(_order, adj_disp, _time, index_end);

    for (unsigned int i = 0; i <= index_end; ++i)
    {
      p_fit = BaselineCorrectionUtils::computePolynomials(_order, coeffs, _time[i]);
      _adj_accel[i] -= p_fit[0];
    }
  }
}

void
BaselineCorrection::buildFromFile()
{
  // Read data from CSV file
  MooseUtils::DelimitedFileReader reader(getParam<FileName>("data_file"), &_communicator);
  reader.read();

  // Check if specific column headers were input
  const bool time_header = isParamValid("time_name"),
             accel_header = isParamValid("acceleration_name");

  if (time_header && !accel_header)
    mooseError("In BaselineCorrection ",
               _name,
               ": A column header name was specified for the for the time data. Please specify a ",
               "header for the acceleration data using the 'accelertation_name' parameter.");
  else if (!time_header && accel_header)
    mooseError("In BaselineCorrection ",
               _name,
               ": A column header name was specified for the for the acceleration data. Please "
               "specify a header for the time data using the 'time_name' parameter.");

  // Obtain acceleration time history from file data
  if (time_header && accel_header)
  {
    _time = reader.getData(getParam<std::string>("time_name"));
    _accel = reader.getData(getParam<std::string>("acceleration_name"));
  }
  else
  {
    _time = reader.getData(0);
    _accel = reader.getData(1);
  }
}

void
BaselineCorrection::buildFromXandY()
{
  _time = getParam<std::vector<Real>>("time_values");
  _accel = getParam<std::vector<Real>>("acceleration_values");
}