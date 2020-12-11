// trying this for @tairoon1

#include "EqualValuePlusConstant.h"
#include "MooseMesh.h"

registerMooseObject("scorpionApp", EqualValuePlusConstant);

InputParameters
EqualValuePlusConstant::validParams()
{
  InputParameters params = NodalConstraint::validParams();
  params.addClassDescription("");
  params.addRequiredParam<Real>("constant", "");
  params.addRequiredParam<std::vector<unsigned int>>("primary", "The primary node IDs.");
  params.addParam<std::vector<unsigned int>>("secondary_node_ids",
                                             "The list of secondary node ids");
  params.addRequiredParam<Real>("penalty", "The penalty used for the boundary term");
  return params;
}

EqualValuePlusConstant::EqualValuePlusConstant(const InputParameters & parameters)
  : NodalConstraint(parameters),
  _constant(getParam<Real>("constant")),
  _primary_node_ids(getParam<std::vector<unsigned int>>("primary")),
  _secondary_node_ids(getParam<std::vector<unsigned int>>("secondary_node_ids")),
  _penalty(getParam<Real>("penalty"))
{
  for (const auto & dof : _secondary_node_ids)
    if (_mesh.nodeRef(dof).processor_id() == _subproblem.processor_id())
      _connected_nodes.push_back(dof);

  // Add elements connected to primary node to Ghosted Elements
  const auto & node_to_elem_map = _mesh.nodeToElemMap();
  for (const auto & dof : _primary_node_ids)
  {
    // defining primary nodes in base class
    _primary_node_vector.push_back(dof);

    auto node_to_elem_pair = node_to_elem_map.find(dof);
    mooseAssert(node_to_elem_pair != node_to_elem_map.end(), "Missing entry in node to elem map");
    const std::vector<dof_id_type> & elems = node_to_elem_pair->second;

    for (const auto & elem_id : elems)
      _subproblem.addGhostedElem(elem_id);
  }
}

Real
EqualValuePlusConstant::computeQpResidual(Moose::ConstraintType type)
{
  unsigned int primary_size = _primary_node_ids.size();

  switch (type)
  {
    case Moose::Primary:
      return (_u_primary[_j] - _u_secondary[_i] + _constant) * _penalty;
    case Moose::Secondary:
      return (_u_secondary[_i] - _u_primary[_j] - _constant) * _penalty;
  }
  return 0.;
}

Real
EqualValuePlusConstant::computeQpJacobian(Moose::ConstraintJacobianType type)
{
  unsigned int primary_size = _primary_node_ids.size();

  switch (type)
  {
    case Moose::PrimaryPrimary:
      return _penalty;
    case Moose::PrimarySecondary:
      return -_penalty;
    case Moose::SecondarySecondary:
      return -_penalty;
    case Moose::SecondaryPrimary:
      return _penalty;
    default:
      mooseError("Unsupported type");
      break;
  }
  return 0.;
}
