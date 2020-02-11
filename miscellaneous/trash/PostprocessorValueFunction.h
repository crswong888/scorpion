#pragma once

#include "Function.h"
#include "LinearInterpolation.h"
#include "VectorPostprocessorInterface.h"

// Forward Declarations
class PostprocessorValueFunction;

template <>
InputParameters validParams<PostprocessorValueFunction>();

/**
 * Add class decription here
 */
class PostprocessorValueFunction : public Function, public VectorPostprocessorInterface
{
public:
  PostprocessorValueFunction(const InputParameters & parameters);

  virtual Real value(Real t, const Point &) const override;

protected:
  std::unique_ptr<LinearInterpolation> _linear_interp;

  const VectorPostprocessorValue & _args;
  const VectorPostprocessorValue & _vpp_values;
  const unsigned int & _vpp_index;
};
