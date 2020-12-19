#pragma once

// MOOSE includes
#include "Material.h"
#include "RankTwoTensor.h"

/**
 * <Description>
 */
class ComputeRigidBeamStrain : public Material
{
public:
  static InputParameters validParams();

  ComputeRigidBeamStrain(const InputParameters & parameters);

  virtual void computeProperties() override;

protected:
  virtual void initQpStatefulProperties() override;

  /// Computes the displacement and rotation strain increments
  void computeQpStrain();

  /// Computes the stiffness matrices
  void computeStiffnessMatrix();

  /// Number of coupled displacement variables
  const unsigned int _ndisp;

  /// Number of coupled rotational variables
  const unsigned int _nrot;

  /// Variable numbers corresponding to the displacement variables
  std::vector<unsigned int> _disp_num;

  /// Variable numbers corresponding to the rotational variables
  std::vector<unsigned int> _rot_num;

  /// penalty coefficient
  const Real _penalty;

  /// Beam elastic properties - here, these are controlled by the penalty coeffiecient
  MaterialProperty<RealVectorValue> & _material_stiffness;
  MaterialProperty<RealVectorValue> & _material_flexure;

  /// Principal components of a beam's original length
  RealVectorValue _dxyz;

  /// Initial length of the beam
  MaterialProperty<Real> & _original_length;

  /// Rotational transformation from global coordinate system to initial beam local configuration
  RankTwoTensor _original_local_config;

  /// Rotational transformation from global coordinate system to beam local configuration at time t
  MaterialProperty<RankTwoTensor> & _total_rotation;

  /// Reference to the nonlinear system object
  NonlinearSystemBase & _nl_sys;

  /// Displacement and rotations at the two nodes of the beam in the global coordinate system
  RealVectorValue _disp0, _disp1, _rot0, _rot1;

  /// Gradient of displacement calculated in the beam local configuration at time t
  RealVectorValue _grad_disp_0_local_t;

  /// Gradient of rotation calculated in the beam local configuration at time t
  RealVectorValue _grad_rot_0_local_t;

  /// Average rotation calculated in the beam local configuration at time t
  RealVectorValue _avg_rot_local_t;

  /// Mechanical displacement strain increment (after removal of eigenstrains) integrated over the cross-section.
  MaterialProperty<RealVectorValue> & _disp_strain_increment;

  /// Mechanical rotation strain increment (after removal of eigenstrains) integrated over the cross-section
  MaterialProperty<RealVectorValue> & _rot_strain_increment;

  /// Stiffness matrix between displacement DOFs of same node or across nodes
  MaterialProperty<RankTwoTensor> & _K11;

  /// Stiffness matrix between displacement DOFs of one node to rotational DOFs of another node
  MaterialProperty<RankTwoTensor> & _K21_cross;

  /// Stiffness matrix between displacement DOFs and rotation DOFs of the same node
  MaterialProperty<RankTwoTensor> & _K21;

  /// Stiffness matrix between rotation DOFs of the same node
  MaterialProperty<RankTwoTensor> & _K22;

  /// Stiffness matrix between rotation DOFs of different nodes
  MaterialProperty<RankTwoTensor> & _K22_cross;
};
