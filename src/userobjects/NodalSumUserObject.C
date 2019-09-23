#include "NodalSumUserObject.h"

registerMooseObject("scorpionApp", NodalSumUserObject);

template <>
InputParameters
validParams<NodalSumUserObject>()
{
  InputParameters params = validParams<NodalUserObject>();
  params.set<bool>("unique_node_execute") = true;
  params.addClassDescription(
  		"Computes the sum of all of the nodal values of the specified "
      "variable. This object sets the default \"unique_node_execute\" "
      "flag to true to avoid double counting nodes between shared blocks.");
  return params;
}

NodalSumUserObject::NodalSumUserObject(const InputParameters & parameters)
	: NodalUserObject(parameters)
{
}

void
NodalSumUserObject::initialize()
{
  _sum.clear();
}

void
NodalSumUserObject::execute()
{
  std::vector<Real> nodeValue(assembly.node());

  _sum[_qp] +=
}

void
NodalSumUserObject::threadJoin(const UserObject & y)
{
  NodalSum::threadJoin(y);
}

Real
NodalSumUserObject::nodalSum(const Node *node) const
{
  std::map<const Node *, Real>::const_iterator it = _
}
