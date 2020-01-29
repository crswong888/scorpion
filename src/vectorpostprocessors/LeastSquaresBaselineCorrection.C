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
      " "); // mastodon response history builder? - if postprocessing
  params.addRequiredParam<std::string>("accel_name", " ");
  params.addRequiredParam<std::string>("time_name", " ");
  params.addParam<Real>("start_time", " ");
  params.addParam<Real>("end_time", " ");
  params.addRequiredParam<unsigned int>("order", " ");
  params.addRequiredParam<Real>("beta", "beta parameter for Newmark time integration.");
  params.addRequiredParam<Real>("gamma", "gamma parameter for Newmark time integration.");
  // other params to be included eventually:
  // fit displacement?
  // manually set coeffs? if yes -> input vector 'a0, a1, a2, ...'
  // output poly coefficients?
  // output unadjusted time histories?
  // output time vector?
  params.addClassDescription(
      " ");
  return params;
}

LeastSquaresBaselineCorrection::LeastSquaresBaselineCorrection(const InputParameters & parameters)
  : GeneralVectorPostprocessor(parameters),
    _vpp_name(getParam<VectorPostprocessorName>("vectorpostprocessor")),
    _accel_name(getParam<std::string>("accel_name")),
    _time_name(getParam<std::string>("time_name")),
    _accel(getVectorPostprocessorValue("vectorpostprocessor", _accel_name)),
    _t(getVectorPostprocessorValue("vectorpostprocessor", _time_name)),
    _time_start(getParam<Real>("start_time")),
    _time_end(getParam<Real>("end_time")),
    _order(parameters.get<unsigned int>("order")),
    _gamma(getParam<Real>("gamma")),
    _beta(getParam<Real>("beta")),
    _time(declareVector("time")),
    _unadj_accel(declareVector("unadjusted_acceleration")),
    _unadj_vel(declareVector("unadjusted_velocity")),
    _unadj_disp(declareVector("unadjusted_displacement")),
    _adj_accel(declareVector("adjusted_acceleration")),
    _adj_vel(declareVector("adjusted_velocity")),
    _adj_disp(declareVector("adjusted_displacement"))
{
  // can set which vectors to allocate/output based on input conditions in here
  // set _var(NULL) in object variable setup

  // eventually need to normalize time domain with t - t0
}

void
LeastSquaresBaselineCorrection::initialize()
{
  _time.clear();
  _unadj_accel.clear();
  _unadj_vel.clear();
  _unadj_disp.clear();
  _adj_accel.clear();
  _adj_vel.clear();
  _adj_disp.clear();
  _time.clear();
}

void
LeastSquaresBaselineCorrection::execute()
{
  // create a copy of the acceleration data so it can be passed to functions
  std::vector<Real> t_var(_t.begin(), _t.end());
  std::vector<Real> accel_var(_accel.begin(), _accel.end());
  unsigned int index_end = accel_var.size() - 1;

  // Compute the unadjusted velocity and displacment time histories
  Real dt;
  std::vector<Real> unadj_vel, unadj_disp;
  unadj_vel.push_back(0); unadj_disp.push_back(0); /* initialize */
  for (unsigned int i = 0; i < index_end; ++i)
  {
    dt = t_var[i+1] - t_var[i];

    unadj_vel.push_back(newmarkGammaIntegrate(
      accel_var[i], accel_var[i+1], unadj_vel[i], _gamma, dt));
    unadj_disp.push_back(newmarkBetaIntegrate(
      accel_var[i], accel_var[i+1], unadj_vel[i], unadj_disp[i], _beta, dt));
  }

  // compute velocity p-fit coefficients from system of linear normal eqns
  DenseVector<Real> coeffs = computeVelocityFitCoeffs(
    _order, accel_var, unadj_vel, t_var, _time_end, index_end, _beta);

  // compute the adjusted time histories from the velocity fit
  Real p_ddot, p_dot, p;
  std::vector<Real> adj_accel, adj_vel, adj_disp;
  for (unsigned int i = 0; i <= index_end; ++i)
  {
    p_ddot = 0; p_dot = 0; p = 0; /* clear old values */

    for (unsigned int k = 0; k < _order + 1; ++k) /* compute polynomials */
    {
      p_ddot += (k * k + 3 * k + 2) * coeffs(k) * pow(t_var[i], k);
      p_dot += (k + 2) * coeffs(k) * pow(t_var[i], k + 1);
      p += coeffs(k) * pow(t_var[i], k + 2);
    }

    adj_accel.push_back(accel_var[i] - p_ddot);
    adj_vel.push_back(unadj_vel[i] - p_dot);
    adj_disp.push_back(unadj_disp[i] - p);
  }

  // note: pass gamma = 0.5 to newmarkGammaIntegrate for trapezoidal

  // assign computed values in the dummy arrays to the output variables
  _time = t_var;
  _unadj_accel = accel_var;
  _unadj_vel = unadj_vel;
  _unadj_disp = unadj_disp;
  _adj_accel = adj_accel;
  _adj_vel = adj_vel;
  _adj_disp = adj_disp;
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
LeastSquaresBaselineCorrection::computeVelocityFitCoeffs(unsigned int order,
                                                         const std::vector<Real> & accel,
                                                         const std::vector<Real> & vel,
                                                         const std::vector<Real> & t,
                                                         const Real & t_end,
                                                         const unsigned int & num_steps,
                                                         const Real & beta)
{
  unsigned int num_rows = order + 1; /* no. of eqns to solve for coefficients */
  DenseMatrix<Real> mat(num_rows, num_rows);
  DenseVector<Real> rhs(num_rows);
  DenseVector<Real> coeffs(num_rows);

  // compute the matrix of the linear normal equation
  for (unsigned int row = 0; row < num_rows; ++row) {
    for (unsigned int col = 0; col < num_rows; ++col)
    {
      mat(row, col) = pow(t_end, row + col + 3) * (col + 2) / (row + col + 3);
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
        u_ddot_old = pow(t[i], row + 1) * accel[i] +
                     (row + 1) * pow(t[i], row) * vel[i];
        u_ddot = pow(t[i+1], row + 1) * accel[i+1] +
                 (row + 1) * pow(t[i+1], row) * vel[i+1];

        rhs(row) += newmarkBetaIntegrate(
        	u_ddot_old, u_ddot, u_dot_old, 0.0, beta, dt);
    }
  }

  // solve the system using libMesh lu factorization
  mat.lu_solve(rhs, coeffs);
  return coeffs;
}
