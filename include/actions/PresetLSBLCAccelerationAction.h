#pragma once

#include "Action.h"

/**
 * Add class decription here
 */
class PresetLSBLCAccelerationAction : public Action
{
public:
  PresetLSBLCAccelerationAction(const InputParameters & params);

  virtual void act() override;

private:
};

template <>
InputParameters validParams<PresetLSBLCAccelerationAction>();
