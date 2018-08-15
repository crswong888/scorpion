#include "scorpionApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

template <>
InputParameters
validParams<scorpionApp>()
{
  InputParameters params = validParams<MooseApp>();
  return params;
}

scorpionApp::scorpionApp(InputParameters parameters) : MooseApp(parameters)
{
  Moose::registerObjects(_factory);
  ModulesApp::registerObjects(_factory);
  scorpionApp::registerObjects(_factory);

  Moose::associateSyntax(_syntax, _action_factory);
  ModulesApp::associateSyntax(_syntax, _action_factory);
  scorpionApp::associateSyntax(_syntax, _action_factory);

  Moose::registerExecFlags(_factory);
  ModulesApp::registerExecFlags(_factory);
  scorpionApp::registerExecFlags(_factory);
}

scorpionApp::~scorpionApp() {}

void
scorpionApp::registerApps()
{
  registerApp(scorpionApp);
}

void
scorpionApp::registerObjects(Factory & factory)
{
    Registry::registerObjectsTo(factory, {"scorpionApp"});
}

void
scorpionApp::associateSyntax(Syntax & /*syntax*/, ActionFactory & action_factory)
{
  Registry::registerActionsTo(action_factory, {"scorpionApp"});

  /* Uncomment Syntax parameter and register your new production objects here! */
}

void
scorpionApp::registerObjectDepends(Factory & /*factory*/)
{
}

void
scorpionApp::associateSyntaxDepends(Syntax & /*syntax*/, ActionFactory & /*action_factory*/)
{
}

void
scorpionApp::registerExecFlags(Factory & /*factory*/)
{
  /* Uncomment Factory parameter and register your new execution flags here! */
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
scorpionApp__registerApps()
{
  scorpionApp::registerApps();
}

extern "C" void
scorpionApp__registerObjects(Factory & factory)
{
  scorpionApp::registerObjects(factory);
}

extern "C" void
scorpionApp__associateSyntax(Syntax & syntax, ActionFactory & action_factory)
{
  scorpionApp::associateSyntax(syntax, action_factory);
}

extern "C" void
scorpionApp__registerExecFlags(Factory & factory)
{
  scorpionApp::registerExecFlags(factory);
}
