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

  virtual void threadJoin(const UserObject & y) override;
  virtual void initialize() override;
  virtual void execute() override;
  virtual void finalize() override;
  virtual Real nodalSum(const Node & node) const;

protected:

  // this stores the variable to be summed
  const VariableValue & _u;
  // this stores the value of that sum at all nodes
  Real _sum;
  //std::map<const Node *, Real> _sum;
};
