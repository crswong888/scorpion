#include "PenaltyFlexuralBC.h"

registerMooseObject("scorpionApp", PenaltyFlexuralBC);

template <>
InputParameters
validParams<PenaltyFlexuralBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<RealVectorValue>("neutral_axis_origin",
      "Origin of the neutral axis");
      // axis origin can be any coordinates on neutral axis
  params.addRequiredParam<RealVectorValue>("axis_direction",
      "Direction of the neutral axis");
  params.addRequiredParam<unsigned int>("component",
      "An integer corresponding to the direction (0 for x, 1 for y, 2 for z)");
  params.addRequiredCoupledVar("displacements",
      "The vector of displacement variables");
  params.addRequiredParam<Real>("penalty",
      "The penalty stiffness coefficient");
  params.addClassDescription(
      "Penalty Enforcement constraining a boundary to rotate about a defined "
      "neutral axis as a rigid surface. This BC can be used to model simple "
      "beam supports on 3D meshes.");
  return params;
}

PenaltyFlexuralBC::PenaltyFlexuralBC(const InputParameters & parameters)
  : IntegratedBC(parameters),
    _y_bar(getParam<RealVectorValue>("neutral_axis_origin")),
    _axis_direction(getParam<RealVectorValue>("axis_direction")),
    _component(getParam<unsigned int>("component")),
    _disp(3),
    _ndisp(coupledComponents("displacements")),
    _disp_var(_ndisp),
    _penalty(getParam<Real>("penalty"))
{
  for (unsigned int i = 0; i < _ndisp; i++)
  {
    _disp[i] = &coupledValue("displacements", i);
    _disp_var[i] = coupled("displacements", i);
  }

  // warning: axis_direction must be unit vector from 0 to 1
}

Real
PenaltyFlexuralBC::computeQpResidual()
{
  std::cout<< "\n\nFOR QUADRATURE POINT (" << (_q_point[_qp])(0) << ", ";
  std::cout<< (_q_point[_qp])(1) << ", " << (_q_point[_qp])(2) << ")\n\n";

  std::cout << "disp[0] = " << (*_disp[0])[_qp];
  std::cout << ", disp[1] = " << (*_disp[1])[_qp];
  std::cout << ", & disp[2] = " << (*_disp[2])[_qp] << "\n";

  // normalize all points relative to p
  std::vector<Real> p0(3);
  std::vector<Real> r0(3);
  //Real p_dot_p(0);
  //Real r_SqMag(0);
  for (unsigned i(0); i < 3; i++)
  {
    // normalize all points relative to the neutral axis
    p0[i] = (_q_point[_qp])(i) - (_q_point[_qp])(i) * _axis_direction(i);
    r0[i] = _y_bar(i) - p0[i];

    std::cout << "r0[" << i << "] = " << r0[i] << ", ";

    // compute the dot product of p with itself
    //p_dot_p += p0[i] * p0[i];
    //std::cout << "p_dot_p = " << p_dot_p << ", ";

    // compute the square magnitude of the initial centroidal arm
    //r_SqMag += (p0[i] - _y_bar(i)) * (p0[i] - _y_bar(i));
    //std::cout << "r_SqMag = " << r_SqMag << " || ";
  }

  // compute the displacement component of the residual
  Real v(0) ;
  for (unsigned i(0); i < _ndisp; i++)
  {
    v += 2. * r0[i] * (*_disp[i])[_qp] + (*_disp[i])[_qp] * (*_disp[i])[_qp];
  }

  std::cout << " || " << "v = " << v << " || ";

  return _penalty * _test[_i][_qp] * v;
}

Real
PenaltyFlexuralBC::computeQpJacobian()
{
  Real p0 = (_q_point[_qp])(_component)
            - (_q_point[_qp])(_component) * _axis_direction(_component);
  Real r0 = _y_bar(_component) - p0;

  std::cout << "r0[" << _component << "] = " << p0 << " || ";

  return 2. * _penalty * _test[_i][_qp] * (r0 + (*_disp[_component])[_qp])
         * _phi[_j][_qp];
}

Real
PenaltyFlexuralBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  for (unsigned coupled_component(0); coupled_component < _ndisp; coupled_component++)
    if (jvar == _disp_var[coupled_component])
    {
      Real p0 = (_q_point[_qp])(coupled_component)
                - (_q_point[_qp])(coupled_component)
                * _axis_direction(coupled_component);
      Real r0 = _y_bar(coupled_component) - p0;

      return 2. * _penalty * _test[_i][_qp]
             * (r0 + (*_disp[coupled_component])[_qp]) * _phi[_j][_qp];
    }

  return 0.0;
}

/*Real
PenaltyFlexuralBC::computeQpResidual()
{
  std::cout<< "FOR QUADRATURE POINT (" << (_q_point[_qp])(0) << ", ";
  std::cout<< (_q_point[_qp])(1) << ", " << (_q_point[_qp])(2) << ")\n\n";

  std::cout << "disp[0] = " << (*_disp[0])[_qp];
  std::cout << ", disp[1] = " << (*_disp[1])[_qp];
  std::cout << ", & disp[2] = " << (*_disp[2])[_qp] << "\n";

  std::vector<Real> r(_ndisp);
  Real sq_mag(0);
  for (unsigned i(0); i < _ndisp; i++)
  {
    r[i] = _transverse_direction(i) * ((_q_point[_qp])(i) - _y_bar(i));
    std::cout << "(i = " << i << "): r[" << i << "] = " << r[i] << ", ";

    sq_mag += r[i] * r[i];
    std::cout << "sq_mag = " << sq_mag << " || ";
  }

  std::cout << "\n";

  std::vector<Real> r_prime(_ndisp);
  Real r_mag = std::sqrt(sq_mag), u_dot_r_prime(0), r_dot_r_prime(0);

  for (unsigned i(0); i < _ndisp; i++)
  {
    if (r[i] >= 0)
      r_prime[i] = r[i] + r_mag * _transverse_direction(i);
    else
      r_prime[i] = r[i] - r_mag * _transverse_direction(i);
    std::cout << "(i = " << i << "): r_prime[" << i << "] = " << r_prime[i] << ", ";

    if (i != _component)
      u_dot_r_prime += (*_disp[i])[_qp] * r_prime[i];
    std::cout << "u_dot_r_prime = " << u_dot_r_prime << ", ";

    r_dot_r_prime += r[i] * r_prime[i];
    std::cout << "r_dot_r_prime = " << r_dot_r_prime << " || ";
  }

  Real res = -(r_dot_r_prime + u_dot_r_prime) / r_prime[_component];

  std::cout << "\nthe residual of component " << _component << " is " << res;
  std::cout << "\n------------------------------------------------------------";
  std::cout << "------------------------------------------------------------\n";

  return _penalty * _test[_i][_qp] * res;
}

Real
PenaltyFlexuralBC::computeQpJacobian()
{
  return _penalty * _phi[_j][_qp] * _normals[_qp](_component) * _normals[_qp](_component) *
         _test[_i][_qp];
}

Real
PenaltyFlexuralBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  for (unsigned int coupled_component = 0; coupled_component < _ndisp; coupled_component++)
    if (jvar == _disp_var[coupled_component])
    {
      return _penalty * _phi[_j][_qp] * _normals[_qp](coupled_component) *
             _normals[_qp](_component) * _test[_i][_qp];
    }

  return 0.0;
}*/
