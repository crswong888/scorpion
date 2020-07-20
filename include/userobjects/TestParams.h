#pragma once

// MOOSE includes
#include "UserObject.h"

// Forward Declarations
class TestParams;

class TestParams : public UserObject
{
public:
  static InputParameters validParams();

  TestParams(const InputParameters & parameters);

  virtual void threadJoin(const UserObject & y) override;
  virtual void initialize() override;
  virtual void execute() override;
  virtual void finalize() override;
};
