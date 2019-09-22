#pragma once

#include "NodalBC.h"

// MOOSE includes
#include "ColumnMajorMatrix.h"

class PenaltyFlexuralBC;

template<>
InputParameters validParams<PenaltyFlexuralBC>();

/**
 * Penalty Enforcement constraining a boundary to rotate about a defined
 * neutral axis as a rigid surface. This BC can be used to model simple
 * beam supports on 3D meshes.
 */
class PenaltyFlexuralBC : public NodalBC
{
public:
  PenaltyFlexuralBC(const InputParameters & parameters);

protected:
  virtual void computeConstraintSurfaceNormal();

  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const Point _y_bar;
  //Point _axis_direction;
  Point _transverse_direction;
  const unsigned int _component;

  // Coupled displacement variables
  std::vector<const VariableValue *> _disp;
  unsigned int _ndisp;
  std::vector<unsigned int> _disp_var;

  ColumnMajorMatrix surface_norm;

private:
  Real _penalty;
};
