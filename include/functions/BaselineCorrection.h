#pragma once

// MOOSE includes
#include "Function.h"
#include "LinearInterpolation.h"

// Forward Declarations
class BaselineCorrection;

/**
 * Applies a baseline correction to an accceleration time history using least
 * squares polynomial fits and outputs the adjusted acceleration
 */
class BaselineCorrection : public Function
{
public:
  static InputParameters validParams();

  BaselineCorrection(const InputParameters & parameters);

  virtual Real value(Real t, const Point & /*P*/) const override;

protected:
  // Newmark integration parameters
  const Real & _gamma;
  const Real & _beta;

  // order used for the least squares polynomial fit
  const unsigned int _order;

  // set which kinematic variables a polynomial fit will be applied to
  const bool _fit_accel;
  const bool _fit_vel;
  const bool _fit_disp;

  // acceleration time history variables from input
  std::vector<Real> _time;
  std::vector<Real> _accel;

  // adjusted (corrected) acceleration ordinates
  std::vector<Real> _adj_accel;

  // object to output linearly interpolated corrected acceleration ordinates
  std::unique_ptr<LinearInterpolation> _linear_interp;

private:
  /// Applies baseline correction to raw acceleration time history
  void applyCorrection();

  /// Reads data from supplied CSV file.
  void buildFromFile();
};
