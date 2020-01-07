#pragma once

#include "IntegratedBC.h"

class PenaltyInclinedNoDisplacementBC;
class Function;

template <>
InputParameters validParams<PenaltyInclinedNoDisplacementBC>();

/**
 * Weakly enforce an inclined BC (u\dot n = 0) using a penalty method.
 */
class PenaltyInclinedNoDisplacementBC : public IntegratedBC
{
public:
  static InputParameters validParams();

  PenaltyInclinedNoDisplacementBC(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;
  virtual Real computeQpJacobian() override;
  virtual Real computeQpOffDiagJacobian(unsigned int jvar) override;

  const unsigned int _component;

  /// Coupled displacement variables
  unsigned int _ndisp;
  std::vector<const VariableValue *> _disp;
  std::vector<unsigned int> _disp_var;

private:
  Real _penalty;
};
