#include "VectorPostprocessor.h"

registerMooseObject("scorpionApp", VectorPostprocessorIC);

template <>
InputParameters
validParams<VectorPostprocessorIC>()
{
  InputParameters params = validParams<InitialCondition>();
  params.addRequiredParam<VectorPostprocessorName>("vectorpostprocessor",
      " ");
}
