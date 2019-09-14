#include "PenaltyFlexuralBC.h"

registerMooseObject("scorpionApp", PenaltyFlexuralBC);

template <>
InputParameters
validParams<PenaltyFlexuralBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<Real>("penalty", "Penalty parameter");
  params.addRequiredCoupledVar("displacements",
      "The vector of displacement variables");
  params.addRequiredParam<unsigned int>("component",
      "An integer corresponding to the direction (0 for x, 1 for y, 2 for z)");
  params.addRequiredParam<RealVectorValue>("axis_origin",
      "Origin of the neutral axis");
      // axis origin can be any coordinates
  params.addRequiredParam<RealVectorValue>("axis_direction",
      "Direction of the neutral axis");
  params.addRequiredParam<RealVectorValue>("transverse_direction",
      "Direction of the transverse direction");
      // directions must be unit vectors
  params.addClassDescription(
      "Penalty Enforcement constraining a boundary to rotate about a defined "
      "neutral axis as a rigid surface. This BC can be used to model simple "
      "beam supports on 3D meshes.");
  return params;
}

PenaltyFlexuralBC::PenaltyFlexuralBC(const InputParameters & parameters)
  : NodalBC(parameters),
    _ndisp(coupledComponents("displacements")),
    _disp_var(_ndisp)
    _disp(3),
    _component(getParam<unsigned int>("component")),
    _y_bar(getParam<RealVectorValue>("axis_origin")),
    //_axis_direction(getParam<RealVectorValue>("axis_direction"))
    // I'll eventually use this parameter
    _penalty(getParam<Real>("penalty"))
{
  for (unsigned int i = 0; i < _ndisp; ++i)
  {
    _disp[i] = &coupledValue("displacements", i);
    _disp_var[i] = coupled("displacements", i);
  }

  // warning, transverse_direction same as axis_direction or axial_direction
}

void
PenaltyFlexuralBC::computeConstraintSurfaceNormal() {
  Point p(*_current_node);

  Real y = transverse_direction * (p - _y_bar);
       theta = std:acos((*_disp[0])[_qp] / y);
       tan_0 = -y * std:cos(theta);
       tan_1 = y * std:cos(theta) ;

  // these unit normals are totally going to depend on which displacement
  // component is being used for each
  ColumnMajorMatrix surface_norm(0, 0) = tan_0 / std:sqrt(tan_0 * tan_0 + tan_1 * tan_1);
                    surface_norm(1, 0) = tan_1 / std:sqrt(tan_0 * tan_0 + tan_1 * tan_1);

  return surface_norm;
}

// in this penalty formulation, its similar to the multi-point constraint
// in traditional finite element, i.e.,
// beta_i*u_i + beta_i*u_j ... = b_0
// here, beta_0 is gonna have to be zero for u \dot normal = 0
// except here, beta_0 = 0 = residual

Real
PenaltyFlexuralBC::computeQpResidual()
{
  Real v = 0;
  ColumnMajorMatrix surface_norm = computeConstraintSurfaceNormal();

  for (unsigned int i = 0; i < _ndisp; ++i) // just assume z is 0 for now
    u_dot_n += (*_disp[i])[_qp] * surface_norm(i, 0);

  return _penalty * u_dot_n * surface_norm(_component, 0);
  // I should sum up displacements times normal x or y here to get dot product
  // then I should enforce the bc by returning the individual components
  // of u \dot normal
}

Real
PenaltyFlexuralBC::computeQpJacobian()
{
  ColumnMajorMatrix surface_norm = computeConstraintSurfaceNormal();

  //this is beta_i for K_ii
  //or beta_j for K_jj
  return _penalty * surface_norm(_component, 0) * surface_norm(_component);
}

PenaltyInclinedNoDisplacementBC::computeQpOffDiagJacobian(unsigned int j)
{
  ColumnMajorMatrix surface_norm = computeConstraintSurfaceNormal();

  //this is beta_i * beta_j for K_ij and K_ji
  //beta_i or j being the constraint, i.e., the normal of the circle
  for (unsigned int coupled_component = 0; coupled_component < _ndisp; ++coupled_component)
    if (j == _disp_var[coupled_component])
    {
      return _penalty * surface_norm(_component, 0) * surface_norm(_coupled_component, 0);
    }

  return 0;
}
