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
  params.addRequiredParam<unsigned int>("order", " ");
  params.addParam<Real>("start_time", " ");
  params.addParam<Real>("end_time", " ");
  params.addRequiredRangeCheckedParam<Real>("regularize_dt",
                                            "regularize_dt>0.0",
                                            " "); // mastodonutils
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
    _unadj_accel(getVectorPostprocessorValue("vectorpostprocessor", _accel_name)),
    _order(parameters.get<unsigned int>("order")),
    _time_start(getParam<Real>("start_time")),
    _time_end(getParam<Real>("end_time")),
    _reg_dt(getParam<Real>("regularize_dt")), // mastodon jargon
    _gamma(getParam<Real>("gamma")),
    _beta(getParam<Real>("beta")),
    _unadj_vel(declareVector("unadjusted_velocity")),
    _unadj_disp(declareVector("unadjusted_displacement")),
    _adj_accel(declareVector("adjusted_acceleration")),
    _adj_vel(declareVector("adjusted_velocity")),
    _adj_disp(declareVector("adjusted_displacement")),
    _time(declareVector("time"))
{
  // can set which vectors to allocate/output based on input conditions in here
  // set _var(NULL) in object variable setup

  // eventually need to normalize time domain with t - t0
}

void
LeastSquaresBaselineCorrection::initialize()
{
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
  std::vector<Real> unadj_accel(_unadj_accel.begin(), _unadj_accel.end());

  // Compute the unadjusted velocity and displacment time histories
  std::vector<Real> unadj_vel, unadj_disp;
  unadj_vel.push_back(0); unadj_disp.push_back(0); // initialize
  for (unsigned int i = 0; i < unadj_accel.size(); ++i)
  {
    unadj_vel.push_back(newmarkGammaIntegrate(
      unadj_accel[i], unadj_accel[i+1], unadj_vel[i], _gamma, _reg_dt));
    unadj_disp.push_back(newmarkBetaIntegrate(
      unadj_accel[i], unadj_accel[i+1], unadj_vel[i], unadj_disp[i], _beta, _reg_dt));
  }

  // compute normal equation coefficient matrix for velocity fit
  unsigned int num_rows = _order + 1;
  std::vector<Real> rhs(num_rows);
  std::vector<Real> mat(num_rows * num_rows);

  unsigned int index;
  for (unsigned int row = 0; row < num_rows; ++row) {
    for (unsigned int i = 0; i < num_rows; ++i)
    { // im gonna need a time vector here
      //rhs[row] +=
    }

    for (unsigned int col = 0; col < num_rows; ++col)
    {
      index = row * num_rows + col;
      mat[index] = pow(_time_end, (row + col + 3)) * (col + 2) / (row + col + 3);

      std::cout << "mat[" << index << "] = " << mat[index] << "\n";
    }
  }

  // note: pass gamma = 0.5 to newmarkGammaIntegrate for trapezoidal


  // assign computed values in the dummy arrays to the output variables
  _unadj_vel = unadj_vel;
  _unadj_disp = unadj_disp;
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
  return u_old + dt * u_dot_old + (0.5 - beta) * dt * dt * u_ddot_old
         + beta * dt * dt * u_ddot;
}

// ****old approach****
/*std::vector<Real>
LeastSquaresBaselineCorrection::newmarkGammaIntegrate(const Real & num_steps,
                                                      const std::vector<Real> & u_double_dot,
                                                      const Real & gamma,
                                                      const Real & reg_dt)
{
  std::vector<Real> u_dot; u_dot.push_back(0);
  Real u_dot_new, u_dot_old = 0;
  for (unsigned int i = 0; i < num_steps; ++i)
  {
    u_dot_new = u_dot_old + (1 - gamma) * reg_dt * u_double_dot[i]
                + gamma * reg_dt * u_double_dot[i+1];
    u_dot_old = u_dot_new; // swap pointers
    u_dot.push_back(u_dot_new);
  }
  return u_dot;
}

std::vector<Real>
LeastSquaresBaselineCorrection::newmarkBetaIntegrate(const Real & num_steps,
                                                     const std::vector<Real> & u_double_dot,
                                                     const std::vector<Real> & u_dot,
                                                     const Real & beta,
                                                     const Real & reg_dt)
{
  std::vector<Real> u; u.push_back(0);
  Real u_new, u_old = 0;
  for (unsigned int i = 0; i < num_steps; ++i)
  {
    u_new = u_old + reg_dt * u_dot[i]
            + (0.5 - beta) * reg_dt * reg_dt * u_double_dot[i]
            + beta * reg_dt * reg_dt * u_double_dot[i+1];
    u_old = u_new; // swap pointers
    u.push_back(u_new);
  }
  return u;
}*/
