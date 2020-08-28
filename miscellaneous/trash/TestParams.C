#include "TestParams.h"

registerMooseObject("scorpionApp", TestParams);

InputParameters
TestParams::validParams()
{
  InputParameters params = UserObject::validParams();

  params.addParam<std::string>("foo", "A string parameter.");
  params.addParam<unsigned int>("bar", "An integer parameter.");
  params.addParam<std::vector<unsigned int>>("baz", "A vector of integers parameter.");

  //params.makeParamRequired<unsigned int>("bar");

  params.makeParamsDependent("foo bar baz");

  return params;
}

TestParams::TestParams(const InputParameters & parameters)
  : UserObject(parameters)
{
}

void
TestParams::threadJoin(const UserObject & /*y*/)
{
}

void
TestParams::initialize()
{
}

void
TestParams::execute()
{
}

void
TestParams::finalize()
{
}
