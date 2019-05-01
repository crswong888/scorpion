#ifndef VARIABLEELASTICMODULUS_H
#define VARIABLEELASTICMODULUS_H

#include "ComputeElasticityTensorBase.h"

class VariableElasticModulus;

template <>
InputParameters validParams<VariableElasticModulus>();

class VariableElasticModulus : public ComputeElasticityTensorBase
{
public:
  VariableElasticModulus(const InputParameters & parameters);

protected:
  virtual void computeQpElasticityTensor() override;

  const VariableValue & _youngs_modulus;
  const VariableValue & _poissons_ratio;
};

#endif // VARIABLEELASTICMODULUS_H
