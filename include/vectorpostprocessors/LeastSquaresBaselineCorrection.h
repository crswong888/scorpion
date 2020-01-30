#pragma once

#include "GeneralVectorPostprocessor.h"

// Forward Declarations
class LeastSquaresBaselineCorrection;

template <>
InputParameters validParams<LeastSquaresBaselineCorrection>();

/**
 * Add class decription here
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

  DenseVector<Real> getVelocityFitCoeffs(unsigned int order,
                                         const std::vector<Real> & accel,
                                         const std::vector<Real> & vel,
                                         const std::vector<Real> & t,
                                         const Real & t_end,
                                         const unsigned int & num_steps,
                                         const Real & beta);

  DenseVector<Real> getDisplacementFitCoeffs(unsigned int order,
                                             const std::vector<Real> & disp,
                                             const std::vector<Real> & t,
                                             const Real & t_end,
                                             const unsigned int & num_steps);

  std::vector<Real> computePolynomials(unsigned int order,
                                       const DenseVector<Real> & coeffs,
                                       const Real & t);

  const VectorPostprocessorValue & _accel;
  const VectorPostprocessorValue & _t;

  const Real & _time_start;
  const Real & _time_end;
  const unsigned int _order;
  const Real & _gamma;
  const Real & _beta;

  VectorPostprocessorValue & _time;
  VectorPostprocessorValue & _unadj_accel;
  VectorPostprocessorValue & _unadj_vel;
  VectorPostprocessorValue & _unadj_disp;
  VectorPostprocessorValue & _adj_accel;
  VectorPostprocessorValue & _adj_vel;
  VectorPostprocessorValue & _adj_disp;
};
