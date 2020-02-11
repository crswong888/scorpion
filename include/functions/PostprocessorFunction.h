#pragma once

#include "Function.h"

class PostprocessorFunction : public Function
{
public:
  static InputParameters validParams();

  PostprocessorFunction(const InputParameters & parameters);

  virtual Real value(Real t, const Point & p) const;

protected:
  const PostprocessorValue & _pp;
};
