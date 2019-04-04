//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#ifndef SCORPIONAPP_H
#define SCORPIONAPP_H

#include "MooseApp.h"

class scorpionApp;

template <>
InputParameters validParams<scorpionApp>();

class scorpionApp : public MooseApp
{
public:
  scorpionApp(InputParameters parameters);
  virtual ~scorpionApp();

  static void registerApps();
  static void registerAll(Factory & factory, ActionFactory & action_factory, Syntax & syntax);
};

#endif /* SCORPIONAPP_H */
