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

  VectorPostprocessorName _vpp_name;
  const std::string _accel_name;
  const VectorPostprocessorValue & _unadj_accel;

  const unsigned int _order;
  const Real & _time_start;
  const Real & _time_end;
  const Real & _reg_dt;
  const Real & _gamma;
  const Real & _beta;

  VectorPostprocessorValue & _unadj_vel;
  VectorPostprocessorValue & _unadj_disp;
  VectorPostprocessorValue & _adj_accel;
  VectorPostprocessorValue & _adj_vel;
  VectorPostprocessorValue & _adj_disp;
  VectorPostprocessorValue & _time;
};
