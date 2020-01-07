#include "SemiRigidBeamSupport.h"

registerMooseObject("scorpionApp", SemiRigidBeamSupport);

template <>
InputParameters
validParams<SemiRigidBeamSupport>()
{
  InputParameters params = NodalBC::validParams();
  params.addRequiredParam<Real>("stiffness",
      "");
  params.addClassDescription("");
  return params;
}

SemiRigidBeamSupport::SemiRigidBeamSupport(const InputParameters & parameters)
  : NodalBC(parameters),
    _moment(getMaterialProperty<RealVectorValue>("moments")),
    _k(getParam<Real>("stiffness"))
{
}

Real
SemiRigidBeamSupport::computeQpResidual()
{
  return _u[_qp] - _moment.value(_t, *_current_node) / _k;
}
