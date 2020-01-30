#pragma once

#include "Function.h"
#include "LinearInterpolation.h"
#include "VectorPostprocessorInterface.h"

// Forward Declarations
class PiecewiseLinearVPP;

template <>
InputParameters validParams<PiecewiseLinearVPP>();

/**
 * Add class decription here
 */
class PiecewiseLinearVPP : public Function, public VectorPostprocessorInterface
{
public:
  PiecewiseLinearVPP(const InputParameters & parameters);

  virtual Real value(Real t, const Point & p) const override;

protected:
  std::unique_ptr<LinearInterpolation> _linear_interp;

  const VectorPostprocessorValue & _args;
  const VectorPostprocessorValue & _vals;
};
