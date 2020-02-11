#include "PostprocessorFunction.h"
#include "MooseTypes.h"

registerMooseObject("scorpionApp", PostprocessorFunction);

InputParameters
PostprocessorFunction::validParams()
{
  InputParameters params = Function::validParams();
  params.addRequiredParam<PostprocessorName>(
      "pp", "The name of the postprocessor you are trying to get.");
  return params;
}

PostprocessorFunction::PostprocessorFunction(const InputParameters & parameters)
  : Function(parameters), _pp(getPostprocessorValue("pp"))
{
}

Real
PostprocessorFunction::value(Real /*t*/, const Point & /*p*/) const
{
  std::cout << _pp << "\n"
  return _pp;
}
