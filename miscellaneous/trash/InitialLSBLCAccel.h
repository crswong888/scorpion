#pragma once

#include "GeneralUserObject.h"

class InitialLSBLCAccel : public GeneralUserObject
{
public:
  InitialLSBLCAccel(const InputParameters & parameters);

  virtual ~InitialLSBLCAccel() {}

  /**
 * Called before execute() is ever called so that data can be cleared.
 */
 virtual void initialize() {}

 /**
  * Compute the hit positions for this timestep
  */
  virtual void execute() {}

  const Real & getPPValue() const;

  virtual void finalize() {}

protected:
  const PostprocessorValue & _pp_value;
};
