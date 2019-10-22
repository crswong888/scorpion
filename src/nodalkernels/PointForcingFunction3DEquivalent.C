#include "PointForcingFunction3DEquivalent.h"

#include "Function.h"

registerMooseObject("scorpionApp", PointForcingFunction3DEquivalent);

template <>
InputParameters
validParams<PointForcingFunction3DEquivalent>()
{
  InputParameters params = validParams<NodalKernel>();
  params.addRequiredParam<FunctionName>("function", "The forcing function");
  params.addRequiredCoupledVar("nodal_area",
      "AuxVariable containing the nodal area");
  params.addRequiredParam<PostprocessorName>("total_area_postprocessor",
      "The name of the postprocessor that is going to be computing the "
      "total area of the section.");
/*  params.addRequiredParam<UserObjectName>("total_area_userobject",
      "The name of the UserObject that is going to be computing the "
      "total area of the section.");*/
  params.addClassDescription(
      "This object distributes a specified magnitude of a single force "
      "over a 2D section of a 3D mesh to all nodes on the boundary and "
      "weighs them by their tributary surface area. This modelling approach "
      "is analogous of applying a point force to a 1D beam element.");
  return params;
}

PointForcingFunction3DEquivalent::PointForcingFunction3DEquivalent(const InputParameters & parameters)
  : NodalKernel(parameters),
  _func(getFunction("function")),
  _nodal_area(coupledValue("nodal_area")),
  _total_area(getPostprocessorValue("total_area_postprocessor"))
  //_total_area(getUserObject<NodalSumUserObject>("total_area_userobject"))
{
}

Real
PointForcingFunction3DEquivalent::computeQpResidual()
{
  //std::cout << "the nodal area is " << _nodal_area[_qp] << "\n";
  //std::cout << "the total area is " << _total_area.nodalSum(*_current_node) << "\n";

  return -_func.value(_t, (*_current_node)) * _nodal_area[_qp] / _total_area;
  //return -_func.value(_t, (*_current_node)) * _nodal_area[_qp] / _total_area.nodalSum(*_current_node);
}
