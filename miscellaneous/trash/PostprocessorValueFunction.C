#include "PostprocessorValueFunction.h"

registerMooseObject("scorpionApp", PostprocessorValueFunction);

template <>
InputParameters
validParams<PostprocessorValueFunction>()
{
  InputParameters params = validParams<Function>();
  params.addRequiredParam<VectorPostprocessorName>("vectorpostprocessor", "");
  params.addRequiredParam<std::string>("argument_column",
      "VectorPostprocessor column tabulating the abscissa of the sampled function");
  params.addRequiredParam<std::string>("vector_name",
      "VectorPostprocessor column tabulating the ordinate (function values) "
      "of the sampled function");
  params.addRequiredParam<unsigned int>("index", "");
  params.addClassDescription(
    "");
  return params;
}

PostprocessorValueFunction::PostprocessorValueFunction(const InputParameters & parameters)
  : Function(parameters),
    VectorPostprocessorInterface(this),
    _args(getVectorPostprocessorValue("vectorpostprocessor",
                                      getParam<std::string>("argument_column"))),
    _vpp_values(getVectorPostprocessorValue("vectorpostprocessor",
                                            getParam<std::string>("vector_name"))),
    _vpp_index(getParam<unsigned int>("index"))
{
  _linear_interp = libmesh_make_unique<LinearInterpolation>(_args, _vpp_values);
}

Real
PostprocessorValueFunction::value(Real t, const Point &) const
{
  std::cout << _vpp_values[0] << "\n";
  /*if (_vpp_index >= _vpp_values.size())
    mooseError("In VectorPostprocessorComponent index greater than size of vector");*/
  return _vpp_values[_vpp_index];
}
