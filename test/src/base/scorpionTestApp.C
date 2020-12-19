//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "scorpionTestApp.h"
#include "scorpionApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
scorpionTestApp::validParams()
{
  InputParameters params = scorpionApp::validParams();
  return params;
}

scorpionTestApp::scorpionTestApp(InputParameters parameters) : MooseApp(parameters)
{
  scorpionTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

scorpionTestApp::~scorpionTestApp() {}

void
scorpionTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  scorpionApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"scorpionTestApp"});
    Registry::registerActionsTo(af, {"scorpionTestApp"});
  }
}

void
scorpionTestApp::registerApps()
{
  registerApp(scorpionApp);
  registerApp(scorpionTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
scorpionTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  scorpionTestApp::registerAll(f, af, s);
}
extern "C" void
scorpionTestApp__registerApps()
{
  scorpionTestApp::registerApps();
}
