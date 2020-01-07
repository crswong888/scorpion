#pragma once

#include "NodalBC.h"

class SemiRigidBeamSupport;

template <>
InputParameters validParams<SemiRigidBeamSupport>();

/**
 *class description
 */
class SemiRigidBeamSupport : public NodalBC
{
public:
  SemiRigidBeamSupport(const InputParameters & parameters);

protected:
  virtual Real computeQpResidual() override;

  // Current moment vector in global coordinate system
  const MaterialProperty<RealVectorValue> & _moment;

private:
  Real _k;
};
