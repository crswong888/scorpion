#include "PiecewiseLinearVPP.h"

registerMooseObject("scorpionApp", PiecewiseLinearVPP);

template <>
InputParameters
validParams<PiecewiseLinearVPP>()
{
  InputParameters params = validParams<Function>();
  params.addRequiredParam<VectorPostprocessorName>("vectorpostprocessor",
      " ");
  params.addRequiredParam<std::string>("argument_column",
      "VectorPostprocessor column tabulating the abscissa of the sampled function");
  params.addRequiredParam<std::string>("value_column",
      "VectorPostprocessor column tabulating the ordinate (function values) "
      "of the sampled function");
  params.addClassDescription(
      "Provides piecewise linear interpolation of from two columns of a "
      "VectorPostprocessor");
  return params;
}

PiecewiseLinearVPP::PiecewiseLinearVPP(const InputParameters & parameters)
  : Function(parameters),
    VectorPostprocessorInterface(this),
    _args(getVectorPostprocessorValue("vectorpostprocessor",
                                      getParam<std::string>("argument_column"))),
    _vals(getVectorPostprocessorValue("vectorpostprocessor",
                                      getParam<std::string>("value_column")))
{
  _linear_interp = libmesh_make_unique<LinearInterpolation>(_args, _vals);
}

Real
PiecewiseLinearVPP::value(Real t, const Point &) const
{
  _linear_interp->setData(_args, _vals);
  return _linear_interp->sample(t);
}
