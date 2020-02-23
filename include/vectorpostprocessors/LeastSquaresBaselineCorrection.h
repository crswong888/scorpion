#pragma once

// MOOSE includes
#include "GeneralVectorPostprocessor.h"

// Forward Declarations
class LeastSquaresBaselineCorrection;

template <>
InputParameters validParams<LeastSquaresBaselineCorrection>();

/**
 * Applies a baseline correction to an accceleration time history contained in another
 * vectorpostprocessor using least squares polynomial fits and outputs the adjusted
 * acceleration, velocity, and displacement time histories
 */
class LeastSquaresBaselineCorrection : public GeneralVectorPostprocessor
{
public:
  LeastSquaresBaselineCorrection(const InputParameters & parameters);
  virtual void initialize() override;
  virtual void execute() override;

protected:
  Real newmarkGammaIntegrate(const Real & u_ddot_old,
                             const Real & u_ddot,
                             const Real & u_dot_old,
                             const Real & gamma,
                             const Real & dt);

  Real newmarkBetaIntegrate(const Real & u_ddot_old,
                            const Real & u_ddot,
                            const Real & u_dot_old,
                            const Real & u_old,
                            const Real & beta,
                            const Real & dt);

  DenseVector<Real> getAccelerationFitCoeffs(unsigned int order,
                                             const std::vector<Real> & accel,
                                             const std::vector<Real> & t,
                                             const unsigned int & num_steps,
                                             const Real & gamma);

  DenseVector<Real> getVelocityFitCoeffs(unsigned int order,
                                         const std::vector<Real> & accel,
                                         const std::vector<Real> & vel,
                                         const std::vector<Real> & t,
                                         const unsigned int & num_steps,
                                         const Real & beta);

  DenseVector<Real> getDisplacementFitCoeffs(unsigned int order,
                                             const std::vector<Real> & disp,
                                             const std::vector<Real> & t,
                                             const unsigned int & num_steps);

  std::vector<Real> computePolynomials(unsigned int order,
                                       const DenseVector<Real> & coeffs,
                                       const Real & t);
  // acceleration time history variables from specified vectorpostprocessor
  const VectorPostprocessorValue & _accel;
  const VectorPostprocessorValue & _t;

  // order used for the least squares polynomial fit
  const unsigned int _order;

  // Newmark integration parameters
  const Real & _gamma;
  const Real & _beta;

  // set which kinematic variables a polynomial fit will be applied to
  const bool _fit_accel;
  const bool _fit_vel;
  const bool _fit_disp;

  // the variables used to write out the adjusted time histories
  VectorPostprocessorValue & _time;
  VectorPostprocessorValue & _adj_accel;
  VectorPostprocessorValue & _adj_vel;
  VectorPostprocessorValue & _adj_disp;

  // wether to output nominal time histories from Newmark integration alone
  const bool _out_unadj;

  // the variables used to write out the nominal time histories (if requested)
  VectorPostprocessorValue * _unadj_accel;
  VectorPostprocessorValue * _unadj_vel;
  VectorPostprocessorValue * _unadj_disp;
};
