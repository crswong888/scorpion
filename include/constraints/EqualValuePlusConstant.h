// trying this for @tairoon1

#pragma once

#include "NodalConstraint.h"

class EqualValuePlusConstant;

/**
 */
class EqualValuePlusConstant : public NodalConstraint
{
public:
  static InputParameters validParams();

  EqualValuePlusConstant(const InputParameters & parameters);

protected:
  /**
   * Computes the residual for the current secondary node
   */
  virtual Real computeQpResidual(Moose::ConstraintType type) override;

  /**
   * Computes the jacobian for the constraint
   */
  virtual Real computeQpJacobian(Moose::ConstraintJacobianType type) override;

  //
  const Real & _constant;
  // Holds the primary node ids
  std::vector<unsigned int> _primary_node_ids;
  // Holds the list of secondary node ids
  std::vector<unsigned int> _secondary_node_ids;
  // Penalty if constraint is not satisfied
  const Real & _penalty;
};
