#include "VariableElasticModulus.h"

registerMooseObject("scorpionApp", VariableElasticModulus);

template <>
InputParameters
validParams<VariableElasticModulus>()
{
  InputParameters params = validParams<ComputeElasticityTensorBase>();
  params.addClassDescription(
      "Couples the Young's modulus and Poisson's ratio to a field variable "
      "and computes an isotropic elasticity tensor at those quadature points.");
  params.addCoupledVar("youngs_modulus",
      "The field variable to be coupled to Young's modulus");
  params.addCoupledVar("poissons_ratio",
      "The field variable to be coupled to Poisson's ratio");
  return params;
}

VariableElasticModulus::VariableElasticModulus(const InputParameters & parameters)
  : ComputeElasticityTensorBase(parameters),
    _youngs_modulus(coupledValue("youngs_modulus")),
    _poissons_ratio(coupledValue("poissons_ratio"))
{
  issueGuarantee(_elasticity_tensor_name, Guarantee::ISOTROPIC);
}

void
VariableElasticModulus::computeQpElasticityTensor()
{
  const Real E = _youngs_modulus[_qp];
  const Real nu = _poissons_ratio[_qp];

  _elasticity_tensor[_qp].fillSymmetricIsotropicEandNu(E, nu);
}
