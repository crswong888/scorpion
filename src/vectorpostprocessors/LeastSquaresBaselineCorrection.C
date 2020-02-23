#include "LeastSquaresBaselineCorrection.h"

// MOOSE includes
#include "VectorPostprocessorInterface.h"

registerMooseObject("scorpionApp", LeastSquaresBaselineCorrection);

template <>
InputParameters
validParams<LeastSquaresBaselineCorrection>()
{
  InputParameters params = validParams<GeneralVectorPostprocessor>();
  params.addRequiredParam<VectorPostprocessorName>("vectorpostprocessor",
      "The vectorpostprocessor containing the acceleration time history data to which a baseline "
      "correction will be applied before integration");
  params.addRequiredParam<std::string>("acceleration_name",
      "The name of the acceleration variable in the vectorpostprocessor");
  params.addRequiredParam<std::string>("time_name",
      "The name of the time variable in the vectorpostprocessor");
  params.addRequiredRangeCheckedParam<unsigned int>("order", "order < 10",
      "the order of the polynomial fit(s) used to adjust the nominal time histories (coefficients "
      "of higher order polynomials can be difficult to compute and the method generally becomes "
      "unstable when order >= 10)");
  params.addRequiredParam<Real>("beta", "beta parameter for Newmark time integration");
  params.addRequiredParam<Real>("gamma", "gamma parameter for Newmark time integration");
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
      "Applies a baseline correction to an accceleration time history contained in another "
      "vectorpostprocessor using least squares polynomial fits and outputs the adjusted "
      "acceleration, velocity, and displacement time histories");
  return params;
}

LeastSquaresBaselineCorrection::LeastSquaresBaselineCorrection(const InputParameters & parameters)
  : GeneralVectorPostprocessor(parameters),
    _accel(getVectorPostprocessorValue("vectorpostprocessor",
                                       getParam<std::string>("acceleration_name"))),
    _t(getVectorPostprocessorValue("vectorpostprocessor",
                                   getParam<std::string>("time_name"))),
    _order(parameters.get<unsigned int>("order")),
    _gamma(getParam<Real>("gamma")),
    _beta(getParam<Real>("beta")),
    _fit_accel(parameters.get<bool>("fit_acceleration")),
    _fit_vel(parameters.get<bool>("fit_velocity")),
    _fit_disp(parameters.get<bool>("fit_displacement")),
    _time(declareVector("time")),
    _adj_accel(declareVector("adjusted_acceleration")),
    _adj_vel(declareVector("adjusted_velocity")),
    _adj_disp(declareVector("adjusted_displacement")),
    _out_unadj(parameters.get<bool>("output_unadjusted")),
    _unadj_accel(NULL),
    _unadj_vel(NULL),
    _unadj_disp(NULL)
{
  if (!_fit_accel && !_fit_vel && !_fit_disp)
    mooseWarning("Warning in " + name() +
                 ". Computation of a polynomial fit is set to \"false\" for all three "
                 "kinematic variables. No adjustments will occur and outputs will be the "
                 "nominal time-histories computed from Newmark integration alone.");

  if (_out_unadj)
  {
    _unadj_accel = &declareVector("unadjusted_acceleration");
    _unadj_vel = &declareVector("unadjusted_velocity");
    _unadj_disp = &declareVector("unadjusted_displacement");
  }
}

void
LeastSquaresBaselineCorrection::initialize()
{
  _time.clear();
  _adj_accel.clear();
  _adj_vel.clear();
  _adj_disp.clear();

  if (_out_unadj)
  {
    _unadj_accel->clear();
    _unadj_vel->clear();
    _unadj_disp->clear();
  }
}

void
LeastSquaresBaselineCorrection::execute()
{
  if (_t.size() != _accel.size())
    mooseError("Error in " + name() +
               ". The size of time and acceleration data must be equal.");
  if (_t.size() == 0)
    mooseError("Error in " + name() +
               ". The size of time and acceleration data must be > 0.");

  // create a copy of the acceleration data so it can be passed to functions
  std::vector<Real> t_var(_t.begin(), _t.end()),
                    accel_var(_accel.begin(), _accel.end());
  unsigned int index_end = accel_var.size() - 1; /* store a reference to final index array */

  // Compute unadjusted velocity and displacment time histories
  Real dt;
  std::vector<Real> unadj_vel, unadj_disp;
  unadj_vel.push_back(0); unadj_disp.push_back(0); /* initialize unadjusted time histories */
  for (unsigned int i = 0; i < index_end; ++i)
  {
    dt = t_var[i+1] - t_var[i];

    unadj_vel.push_back(newmarkGammaIntegrate(
        accel_var[i], accel_var[i+1], unadj_vel[i], _gamma, dt));
    unadj_disp.push_back(newmarkBetaIntegrate(
        accel_var[i], accel_var[i+1], unadj_vel[i], unadj_disp[i], _beta, dt));
  }

  // initialize polyfits and the dummy adjusted time history arrays as the nominal ones
  DenseVector<Real> coeffs;
  std::vector<Real> p_fit,
                    adj_accel = accel_var,
                    adj_vel = unadj_vel,
                    adj_disp = unadj_disp;

  // check if acceleration fit shall be applied to corrections
  if (_fit_accel) /* adjust time histories with acceleration fit */
  {
    coeffs = getAccelerationFitCoeffs(_order, adj_accel, t_var, index_end, _gamma);

    for (unsigned int i = 0; i <= index_end; ++i)
    {
      p_fit = computePolynomials(_order, coeffs, t_var[i]);

      adj_accel[i] -= p_fit[0];
      adj_vel[i] -= p_fit[1];
      adj_disp[i] -= p_fit[2];
    }
  }

  // check if velocity fit shall be applied to corrections
  if (_fit_vel) /* adjust time histories with velocity fit */
  {
    coeffs = getVelocityFitCoeffs(_order, adj_accel, adj_vel, t_var, index_end, _beta);

    for (unsigned int i = 0; i <= index_end; ++i)
    {
      p_fit = computePolynomials(_order, coeffs, t_var[i]);

      adj_accel[i] -= p_fit[0];
      adj_vel[i] -= p_fit[1];
      adj_disp[i] -= p_fit[2];
    }
  }

  // check if displacement fit shall be applied to corrections
  if (_fit_disp) /* adjust time histories with displacement fit */
  {
    coeffs = getDisplacementFitCoeffs(_order, adj_disp, t_var, index_end);

    for (unsigned int i = 0; i <= index_end; ++i)
    {
      p_fit = computePolynomials(_order, coeffs, t_var[i]);

      adj_accel[i] -= p_fit[0];
      adj_vel[i] -= p_fit[1];
      adj_disp[i] -= p_fit[2];
    }
  }

  // assign computed values in dummy arrays to output variables
  _time = t_var;
  _adj_accel = adj_accel;
  _adj_vel = adj_vel;
  _adj_disp = adj_disp;

  if (_out_unadj) /* also output unadjusted time histories if requested */
  {
    *_unadj_accel = accel_var;
    *_unadj_vel = unadj_vel;
    *_unadj_disp = unadj_disp;
  }
}

Real
LeastSquaresBaselineCorrection::newmarkGammaIntegrate(const Real & u_ddot_old,
                                                      const Real & u_ddot,
                                                      const Real & u_dot_old,
                                                      const Real & gamma,
                                                      const Real & dt)
{
  return u_dot_old + (1 - gamma) * dt * u_ddot_old + gamma * dt * u_ddot;
}

Real
LeastSquaresBaselineCorrection::newmarkBetaIntegrate(const Real & u_ddot_old,
                                                     const Real & u_ddot,
                                                     const Real & u_dot_old,
                                                     const Real & u_old,
                                                     const Real & beta,
                                                     const Real & dt)
{
  return u_old + dt * u_dot_old + (0.5 - beta) * dt * dt * u_ddot_old +
         beta * dt * dt * u_ddot;
}

DenseVector<Real>
LeastSquaresBaselineCorrection::getAccelerationFitCoeffs(unsigned int order,
                                                         const std::vector<Real> & accel,
                                                         const std::vector<Real> & t,
                                                         const unsigned int & num_steps,
                                                         const Real & gamma)
{
  unsigned int num_rows = order + 1; /* no. of eqns to solve for coefficients */
  DenseMatrix<Real> mat(num_rows, num_rows);
  DenseVector<Real> rhs(num_rows);
  DenseVector<Real> coeffs(num_rows);

  // compute matrix of linear normal equation
  for (unsigned int row = 0; row < num_rows; ++row) {
    for (unsigned int col = 0; col < num_rows; ++col)
    {
      mat(row, col) = pow(t[t.size()-1], row + col + 1) * (col * col + 3 * col + 2) /
                      (row + col + 1);
    }
  }

  // compute vector of integrals on right-hand side of linear normal equation
  Real dt, u_ddot_old, u_ddot;
  for (unsigned int i = 0; i < num_steps; ++i)
  {
    dt = t[i+1] - t[i];
    for (unsigned int row = 0; row < num_rows; ++row)
    {
      u_ddot_old = pow(t[i], row) * accel[i];
      u_ddot = pow(t[i+1], row) * accel[i+1];

      rhs(row) += newmarkGammaIntegrate(u_ddot_old, u_ddot, 0.0, gamma, dt);
    }
  }

  // solve the system using libMesh lu factorization
  mat.lu_solve(rhs, coeffs);
  return coeffs;
}

DenseVector<Real>
LeastSquaresBaselineCorrection::getVelocityFitCoeffs(unsigned int order,
                                                     const std::vector<Real> & accel,
                                                     const std::vector<Real> & vel,
                                                     const std::vector<Real> & t,
                                                     const unsigned int & num_steps,
                                                     const Real & beta)
{
  unsigned int num_rows = order + 1; /* no. of eqns to solve for coefficients */
  DenseMatrix<Real> mat(num_rows, num_rows);
  DenseVector<Real> rhs(num_rows);
  DenseVector<Real> coeffs(num_rows);

  // compute matrix of linear normal equation
  for (unsigned int row = 0; row < num_rows; ++row) {
    for (unsigned int col = 0; col < num_rows; ++col)
    {
      mat(row, col) = pow(t[t.size()-1], row + col + 3) * (col + 2) / (row + col + 3);
    }
  }

  // compute vector of integrals on right-hand side of linear normal equation
  Real dt, u_ddot_old, u_ddot, u_dot_old;
  for (unsigned int i = 0; i < num_steps; ++i)
  {
    dt = t[i+1] - t[i];
    for (unsigned int row = 0; row < num_rows; ++row)
    {
      u_dot_old = pow(t[i], row + 1) * vel[i];
      u_ddot_old = pow(t[i], row + 1) * accel[i] + (row + 1) * pow(t[i], row) * vel[i];
      u_ddot = pow(t[i+1], row + 1) * accel[i+1] + (row + 1) * pow(t[i+1], row) * vel[i+1];

      rhs(row) += newmarkBetaIntegrate(u_ddot_old, u_ddot, u_dot_old, 0.0, beta, dt);
    }
  }

  // solve the system using libMesh lu factorization
  mat.lu_solve(rhs, coeffs);
  return coeffs;
}

DenseVector<Real>
LeastSquaresBaselineCorrection::getDisplacementFitCoeffs(unsigned int order,
                                                         const std::vector<Real> & disp,
                                                         const std::vector<Real> & t,
                                                         const unsigned int & num_steps)
{
  unsigned int num_rows = order + 1;
  DenseMatrix<Real> mat(num_rows, num_rows);
  DenseVector<Real> rhs(num_rows);
  DenseVector<Real> coeffs(num_rows);

  // computer matrix of linear normal equation
  for (unsigned int row = 0; row < num_rows; ++row) {
    for (unsigned int col = 0; col < num_rows; ++col)
    {
      mat(row, col) = pow(t[t.size()-1], row + col + 5) / (row + col + 5);
    }
  }

  // compute vector of integrals on right-hand side of linear normal equation
  Real dt, u_old, u;
  for (unsigned int i = 0; i < num_steps; ++i)
  {
    dt = t[i+1] - t[i];
    for (unsigned int row = 0; row < num_rows; ++row)
    {
      u_old = pow(t[i], row + 2) * disp[i];
      u = pow(t[i+1], row + 2) * disp[i+1];

      // note: newmarkGamma with gamma = 0.5 is trapezoidal rule
      rhs(row) += newmarkGammaIntegrate(u_old, u, 0.0, 0.5, dt);
    }
  }

  // solve the system using libMesh lu factorization
  mat.lu_solve(rhs, coeffs);
  return coeffs;
}

std::vector<Real>
LeastSquaresBaselineCorrection::computePolynomials(unsigned int order,
                                                   const DenseVector<Real> & coeffs,
                                                   const Real & t)
{
  std::vector<Real> p_fit(3); /* accel polyfit and its derivatives */
  for (unsigned int k = 0; k < order + 1; ++k) /* compute polynomials */
  {
    p_fit[0] += (k * k + 3 * k + 2) * coeffs(k) * pow(t, k);
    p_fit[1] += (k + 2) * coeffs(k) * pow(t, k + 1);
    p_fit[2] += coeffs(k) * pow(t, k + 2);
  }

  return p_fit;
}
