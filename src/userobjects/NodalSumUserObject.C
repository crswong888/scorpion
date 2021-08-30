#include "NodalSumUserObject.h"

//#include "Assembly.h"

registerMooseObject("ScorpionApp", NodalSumUserObject);

template <>
InputParameters
validParams<NodalSumUserObject>()
{
  InputParameters params = validParams<NodalUserObject>();
  params.set<bool>("unique_node_execute") = true;
  params.addRequiredCoupledVar("sum_from_variable",
      "The variable for which to compute the sum of all nodal values");
  params.addClassDescription(
  		"Computes the sum of all of the nodal values of the specified "
      "variable. This object sets the default \"unique_node_execute\" "
      "flag to true to avoid double counting nodes between shared blocks.");
  return params;
}

NodalSumUserObject::NodalSumUserObject(const InputParameters & parameters)
	: NodalUserObject(parameters),
  _u(coupledValue("sum_from_variable")),
  _sum(0)
{
}

void
NodalSumUserObject::threadJoin(const UserObject & y)
{
  // need to make sure processors communicate

  //const NodalSumUserObject & pps = static_cast<const NodalSumUserObject &>(y);
  //_sum += pps._sum;
}

void
NodalSumUserObject::initialize()
{
  //_sum.clear();
  _sum = 0.0;
}

void
NodalSumUserObject::execute()
{
/*  std::vector<Real> nodeValues(_assembly.node());
  for (unsigned qp(0); qp < _qrule->n_points(); ++qp)
  {
    for (unsigned j(0); j < _assembly.node(); ++j)
    {
      nodeValues[j] += _u[qp];
    }
  }
  for (unsigned j(0); j < _assembly.node(); ++j)
  {
    const Real value = nodeValues[j];
    _sum[_current_elem->node_ptr(j)] += value
  }*/
  /*for (unsigned qp(0); qp < _qrule->n_points(); ++qp)
  {
    _sum += _u[_qp];
  }*/
  _sum += _u[_qp];
}

void
NodalSumUserObject::finalize()
{
  // idk if I need this function

/*  const std::map<const Node *, Real>::iterator it_end = _sum.end();
  for (std::map<const Node *, Real>::iterator it = _sum.begin(); it != it_end; ++it)*/
}

Real
NodalSumUserObject::nodalSum(const Node & node) const
{
  /*std::map<const Node *, Real>::const_iterator it = _sum.find(node);
  Real retVal(0);
  if (it != _sum.end())
  {
    retVal = it->second;
  }
  return retVal;*/

  return _sum;
}
