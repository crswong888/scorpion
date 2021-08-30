#include "PostprocessorIC.h"

registerMooseObject("ScorpionApp", PostprocessorIC);

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
  : InitialCondition(parameters), _pp_value(getPostprocessorValue("postprocessor"))
{
}

Real
PostprocessorIC::value(const Point & /*p*/)
{
  return _pp_value;
}
