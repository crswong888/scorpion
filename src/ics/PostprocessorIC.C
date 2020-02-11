#include "PostprocessorIC.h"

registerMooseObject("scorpionApp", PostprocessorIC);

template <>
InputParameters
validParams<PostprocessorIC>()
{
  InputParameters params = validParams<InitialCondition>();
  params.addRequiredParam<PostprocessorName>("postprocessor", "");
  params.addClassDescription(
      "");
  return params;
}

PostprocessorIC::PostprocessorIC(const InputParameters & parameters)
  : InitialCondition(parameters),
    PostprocessorInterface(this),
    _pp_value(getPostprocessorValue("postprocessor"))
{
}

Real
PostprocessorIC::value(const Point & /*p*/)
{
  std::cout << _pp_value << "\n";
  return _pp_value;
}
