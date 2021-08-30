#pragma once

#include "InitialCondition.h"

// Forward Declarations
class PostprocessorIC;

template <>
InputParameters validParams<PostprocessorIC>();

/**
 * Add class decription here
 */
class PostprocessorIC : public InitialCondition
{
public:
  PostprocessorIC(const InputParameters & parameters);

  virtual Real value(const Point & /*p*/) override;

protected:
  const PostprocessorValue & _pp_value;
};
