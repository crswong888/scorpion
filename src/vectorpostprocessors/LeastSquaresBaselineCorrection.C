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
    _unadj_accel(getParam<VectorPostprocessorName>("vectorpostprocessor")),
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


std::vector<Real>
LeastSquaresBaselineCorrection::newmarkGammaIntegrate(const Real & num_steps,
                                                      const std::vector<Real> & u_double_dot,
                                                      const Real & gamma,
                                                      const Real & reg_dt)
{
  std::vector<Real> u_dot(num_steps); u_dot[0] = 0; // initialize
  for (unsigned int i = 0; i < num_steps; ++i)
  {
    u_dot[i+1] = u_dot[i] + (1 - gamma) * reg_dt * u_double_dot[i]
                + gamma * reg_dt * u_double_dot[i+1];
  }
  return u_dot;
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

  std::cout << "NUM_STEPS = " << unadj_accel.size();

  // Compute the unadjusted velocity and displacment time histories
  //std::vector<Real> unadj_vel = newmarkGammaIntegrate(
  //    unadj_accel.size(), unadj_accel, _gamma, _reg_dt);

  // note: pass gamma = 0.5 to newmarkGammaIntegrate for trapezoidal


  // assign computed values in the dummy arrays to the output variables
  //_unadj_vel = unadj_vel;
}
