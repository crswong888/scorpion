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

template <>
InputParameters
validParams<scorpionTestApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

registerKnownLabel("scorpionTestApp");

scorpionTestApp::scorpionTestApp(InputParameters parameters) : MooseApp(parameters)
{
  scorpionTestApp::registerAll(
    _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

scorpionTestApp::~scorpionTestApp() {}

// External entry point for dynamic application loading
extern "C" void
scorpionTestApp__registerApps()
{
  scorpionTestApp::registerApps();
}
void
scorpionTestApp::registerApps()
{
  registerApp(scorpionApp);
  registerApp(scorpionTestApp);
}

// External entry point for object registration
extern "C" void
scorpionApp__registerAll(Factory & factory, ActionFactory & action_factory, Syntax & syntax)
{
  scorpionTestApp::registerAll(factory, action_factory, syntax);
}
void
scorpionTestApp::registerAll(Factory & factory,
                          ActionFactory & action_factory,
                          Syntax & syntax,
                          bool use_test_objs)
{
  scorpionApp::registerAll(factory, action_factory, syntax);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(factory, {"scorpionTestApp"});
    Registry::registerActionsTo(action_factory, {"scorpionTestApp"});
  }
}
