#include "InitialLSBLCAccel.h"

registerMooseObject("scorpionApp", InitialLSBLCAccel);

template <>
InputParameters
validParams<InitialLSBLCAccel>()
{
  InputParameters params = validParams<GeneralUserObject>();
  params.addRequiredParam<PostprocessorName>("postprocessor", "");
  params.set<ExecFlagEnum>("execute_on") = EXEC_INITIAL;
  params.addClassDescription(
      "");
  return params;
}

InitialLSBLCAccel::InitialLSBLCAccel(const InputParameters & parameters)
  : GeneralUserObject(parameters),
    _pp_value(getPostprocessorValue("postprocessor"))
{
}

const Real &
InitialLSBLCAccel::getPPValue() const
{
  std::cout << _pp_value << "\n";
  return _pp_value;
}
