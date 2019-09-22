#pragma once

#include "NodalKernel.h"

class PointForcingFunction3DEquivalent;

template <>
InputParameters validParams<PointForcingFunction3DEquivalent>();

/**
 * This object distributes a specified magnitude of a single force
 * over a 2D cross-section of 3D mesh to all nodes on the boundary and
 * weighs them by their tributary surface area. This modelling approach
 * is analogous of applying a point force to a 1D beam element.
 */
class PointForcingFunction3DEquivalent : public NodalKernel
{
public:
  PointForcingFunction3DEquivalent(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;

  const Function & _func;
  const VariableValue & _nodal_area;
  const VariableValue & _total_area;
};
