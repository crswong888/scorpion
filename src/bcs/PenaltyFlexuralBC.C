#include "PenaltyFlexuralBC.h"

registerMooseObject("ScorpionApp", PenaltyFlexuralBC);

template <>
InputParameters
validParams<PenaltyFlexuralBC>()
{
  InputParameters params = validParams<IntegratedBC>();
  params.addRequiredParam<RealVectorValue>("internal_ref_point",
      "");
  params.addRequiredParam<RealVectorValue>("neutral_axis_origin",
      "Coordinate of the neutral axis origin on plane of boundary");
  params.addRequiredParam<RealVectorValue>("axis_direction",
      "Direction of the neutral axis");
  params.addRequiredParam<unsigned int>("component",
      "An integer corresponding to the direction (0 for x, 1 for y, 2 for z)");
  params.addRequiredCoupledVar("displacements",
      "The vector of displacement variables");
  params.addRequiredCoupledVar("normal_stress",
      "");
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
    _p_ref(getParam<RealVectorValue>("internal_ref_point")),
    _y_bar(getParam<RealVectorValue>("neutral_axis_origin")),
    _axis_direction(getParam<RealVectorValue>("axis_direction")),
    _component(getParam<unsigned int>("component")),
    _disp(3),
    _ndisp(coupledComponents("displacements")),
    _disp_var(_ndisp),
    _sigma_xx(coupledValue("normal_stress")),
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
  std::cout << "\n\n\n***************************\n";
  std::cout << "*** computeQpResidual() ***";
  std::cout << "\n***************************\n";

  std::cout << "For QP = (" << (_q_point[_qp])(0) << ", ";
  std::cout << (_q_point[_qp])(1) << ", " << (_q_point[_qp])(2) << ") & ";
  std::cout << "_component = " << _component << ":\n";

  std::cout << "\nCurrent estimate: ";
  std::cout << "disp[0] = " << (*_disp[0])[_qp];
  std::cout << " || disp[1] = " << (*_disp[1])[_qp];
  std::cout << " || disp[2] = " << (*_disp[2])[_qp];
  std::cout << " || sigma_xx = " << _sigma_xx[_qp] << " || ";

  std::cout << "\nComputed centroidal arm vector: ";
  // normalize all points relative to the neutral axis
  std::vector<Real> p(3);
  std::vector<Real> r(3);
  for (unsigned int i = 0; i < 3; i++)
  {
    p[i] = (_q_point[_qp])(i) - (_q_point[_qp])(i) * _axis_direction(i);
    r[i] = p[i] - _y_bar(i);

    std::cout << "r[" << i << "] = " << r[i] << " || ";
  }

  std::cout << "\nComputed coupled sum for components: ";
  // compute the constant sum of the coupled vars part of the residual
  Real sum(0);
  for (unsigned int k = 0; k < _ndisp; k++)
  {
    if (k != _component)
    {
      sum += 2. * r[k] * (*_disp[k])[_qp] + (*_disp[k])[_qp] * (*_disp[k])[_qp];

      std::cout << "k = " << k << ", sum = " << sum << " || ";
    }
  }

  std::cout << "\nComputed the residual with: ";
  // compute the residual
  Real v(0);
  Real strong_res(0);
  if (_component == 0) {
    // compute the unpenalized, strong form of the residual
    Real quad_check = ((_q_point[_qp])(0) - _p_ref(0)) * _sigma_xx[_qp];
    if (quad_check > 0) {
      v = -r[0] + std::sqrt(r[0] * r[0] - sum);
    } else {
      v = -r[0] - std::sqrt(r[0] * r[0] - sum);
    }
    strong_res = (*_disp[0])[_qp] - v;

    std::cout << "quad_check = " << quad_check << " || ";
    std::cout << "v = " << v << " || strong_res = " << strong_res << " || ";
    std::cout << "\nReturning penalized weak form: R = ";
    std::cout << _penalty * _test[_i][_qp] * strong_res;

    // multiply by the penalty and test function
    return _penalty * _test[_i][_qp] * strong_res;
  } else if (_component == 1) {
    // compute the unpenalized, strong form of the residual
    if (r[1] >= 0) {
      v = -r[1] + std::sqrt(r[1] * r[1] - sum);
    } else {
      v = -r[1] - std::sqrt(r[1] * r[1] - sum);
    }
    strong_res = (*_disp[1])[_qp] - v;

    std::cout << "v = " << v << " || strong_res = " << strong_res << " || ";
    std::cout << "\nReturning penalized weak form: R = ";
    std::cout << _penalty * _test[_i][_qp] * strong_res;

    // multiply by the penalty and test function
    return _penalty * _test[_i][_qp] * strong_res;
  }

  return 0;
}

Real
PenaltyFlexuralBC::computeQpJacobian()
{
  return _penalty * _test[_i][_qp] * _phi[_j][_qp];
}

Real
PenaltyFlexuralBC::computeQpOffDiagJacobian(unsigned int jvar)
{
  std::cout << "\n\n\n***************************\n";
  std::cout << "*** computeQpOffDiagJacobian() ***";
  std::cout << "\n***************************\n";

  std::cout << "For QP = (" << (_q_point[_qp])(0) << ", ";
  std::cout << (_q_point[_qp])(1) << ", " << (_q_point[_qp])(2) << ") & ";
  std::cout << "_component = " << _component << ":\n";

  std::cout << "\nCurrent estimate: ";
  std::cout << "disp[0] = " << (*_disp[0])[_qp];
  std::cout << " || disp[1] = " << (*_disp[1])[_qp];
  std::cout << " || disp[2] = " << (*_disp[2])[_qp];
  std::cout << " || sigma_xx = " << _sigma_xx[_qp] << " || ";

  std::cout << "\nComputed centroidal arm vector: ";
  // normalize all points relative to the neutral axis
  std::vector<Real> p(3);
  std::vector<Real> r(3);
  for (unsigned int i = 0; i < 3; i++)
  {
    p[i] = (_q_point[_qp])(i) - (_q_point[_qp])(i) * _axis_direction(i);
    r[i] = p[i] - _y_bar(i);

    std::cout << "r[" << i << "] = " << r[i] << " || ";
  }

  std::cout << "\nComputed coupled sum for components: ";
  // compute the constant sum of the coupled vars part of the residual
  Real sum(0);
  for (unsigned int k = 0; k < _ndisp; k++)
  {
    if (k != _component)
    {
      sum += 2. * r[k] * (*_disp[k])[_qp] + (*_disp[k])[_qp] * (*_disp[k])[_qp];

      std::cout << "k = " << k << ", sum = " << sum << " || ";
    }
  }

  for (unsigned int coupled_id = 0; coupled_id < _ndisp; coupled_id++)
  {
    if (jvar == _disp_var[coupled_id])
    {
      // compute the unpenalized, strong form of the residual
      Real v(0);
      Real res(0);
      if (_component == 0) {
        Real quad_check = ((_q_point[_qp])(0) - _p_ref(0)) * _sigma_xx[_qp];
        if (quad_check > 0) {
          v = std::sqrt(r[0] * r[0] - sum);
        } else {
          v = -std::sqrt(r[0] * r[0] - sum);
        }

        return _penalty * _test[_i][_qp] * _phi[_j][_qp]
               * (r[coupled_id] + (*_disp[coupled_id])[_qp]) / v;
      } else if (_component == 1) {
        if (r[1] >= 0) {
          v = std::sqrt(r[1] * r[1] - sum);
        } else {
          v = -std::sqrt(r[1] * r[1] - sum);
        }

        return _penalty * _test[_i][_qp] * _phi[_j][_qp]
               * (r[coupled_id] + (*_disp[coupled_id])[_qp]) / v;
      }
    }
  }

  return 0;
}
