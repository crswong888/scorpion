//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "ScorpionTestApp.h"
#include "ScorpionApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"
#include "ModulesApp.h"

InputParameters
ScorpionTestApp::validParams()
{
  InputParameters params = ScorpionApp::validParams();
  return params;
}

ScorpionTestApp::ScorpionTestApp(InputParameters parameters) : MooseApp(parameters)
{
  ScorpionTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

ScorpionTestApp::~ScorpionTestApp() {}

void
ScorpionTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  ScorpionApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"ScorpionTestApp"});
    Registry::registerActionsTo(af, {"ScorpionTestApp"});
  }
}

void
ScorpionTestApp::registerApps()
{
  registerApp(ScorpionApp);
  registerApp(ScorpionTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
ScorpionTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ScorpionTestApp::registerAll(f, af, s);
}
extern "C" void
ScorpionTestApp__registerApps()
{
  ScorpionTestApp::registerApps();
}
