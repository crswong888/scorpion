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
  InputParameters params = validParams<scorpionApp>();
  return params;
}

scorpionTestApp::scorpionTestApp(InputParameters parameters) : MooseApp(parameters)
{
  Moose::registerObjects(_factory);
  ModulesApp::registerObjects(_factory);
  scorpionApp::registerObjectDepends(_factory);
  scorpionApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  ModulesApp::associateSyntax(_syntax, _action_factory);
  scorpionApp::associateSyntaxDepends(_syntax, _action_factory);
  scorpionApp::associateSyntax(_syntax, _action_factory);

  Moose::registerExecFlags(_factory);
  ModulesApp::registerExecFlags(_factory);
  scorpionApp::registerExecFlags(_factory);

  bool use_test_objs = getParam<bool>("allow_test_objects");
  if (use_test_objs)
  {
    scorpionTestApp::registerObjects(_factory);
    scorpionTestApp::associateSyntax(_syntax, _action_factory);
    scorpionTestApp::registerExecFlags(_factory);
  }
}

scorpionTestApp::~scorpionTestApp() {}

void
scorpionTestApp::registerApps()
{
  registerApp(scorpionApp);
  registerApp(scorpionTestApp);
}

void
scorpionTestApp::registerObjects(Factory & /*factory*/)
{
  /* Uncomment Factory parameter and register your new test objects here! */
}

void
scorpionTestApp::associateSyntax(Syntax & /*syntax*/, ActionFactory & /*action_factory*/)
{
  /* Uncomment Syntax and ActionFactory parameters and register your new test objects here! */
}

void
scorpionTestApp::registerExecFlags(Factory & /*factory*/)
{
  /* Uncomment Factory parameter and register your new execute flags here! */
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
scorpionTestApp__registerApps()
{
  scorpionTestApp::registerApps();
}

// External entry point for dynamic object registration
extern "C" void
scorpionTestApp__registerObjects(Factory & factory)
{
  scorpionTestApp::registerObjects(factory);
}

// External entry point for dynamic syntax association
extern "C" void
scorpionTestApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  scorpionTestApp::associateSyntax(syntax, action_factory);
}

// External entry point for dynamic execute flag loading
extern "C" void
scorpionTestApp__registerExecFlags(Factory & factory)
{
  scorpionTestApp::registerExecFlags(factory);
}
