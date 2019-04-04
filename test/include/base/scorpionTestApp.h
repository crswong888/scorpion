//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#ifndef SCORPIONTESTAPP_H
#define SCORPIONTESTAPP_H

#include "MooseApp.h"

class scorpionTestApp;

template <>
InputParameters validParams<scorpionTestApp>();

class scorpionTestApp : public MooseApp
{
public:
  scorpionTestApp(InputParameters parameters);
  virtual ~scorpionTestApp();

  static void registerApps();
  static void registerAll(Factory & factory,
                          ActionFactory & action_factory,
                          Syntax & syntax,
                          bool use_test_objs = false);
};

#endif /* SCORPIONTESTAPP_H */
