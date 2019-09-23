#pragma once

// MOOSE includes
#include "NodalUserObject.h"

// Forward Declarations
class NodalSumUserObject;

template <>
InputParameters validParams<NodalSumUserObject>();

/**
 * Computes the sum of all of the nodal values of the variable.
 */
class NodalSumUserObject : public NodalUserObject
{
public:
  NodalSumUserObject(const InputParameters & parameters);

  virtual void initialize() override;
  virtual void execute() override;
  virtual void threadJoin(const UserObject & y) override;
  virtual Real nodal(const Node *node) const;

  const VariableValue & _var;

protected:
  Real _sum;
};
