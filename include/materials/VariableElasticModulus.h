#pragma once

#include "ComputeElasticityTensorBase.h"

class VariableElasticModulus;

template <>
InputParameters validParams<VariableElasticModulus>();

/**
 * Couples the Young's modulus and Poisson's ratio to a field variable
 * and computes an isotropic elasticity tensor at those quadature points.
 */
class VariableElasticModulus : public ComputeElasticityTensorBase
{
public:
  VariableElasticModulus(const InputParameters & parameters);

protected:
  virtual void computeQpElasticityTensor() override;

  const VariableValue & _youngs_modulus;
  const VariableValue & _poissons_ratio;
  // I should do something here eventually to incorporate all the other elastic moduli
};
