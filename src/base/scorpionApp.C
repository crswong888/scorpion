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

registerKnownLabel("scorpionApp");

scorpionApp::scorpionApp(InputParameters parameters) : MooseApp(parameters)
{
  scorpionApp::registerAll(_factory, _action_factory, _syntax);
}

scorpionApp::~scorpionApp() {}

// External entry point for dynamic application loading
extern "C" void
scorpionApp__registerApps()
{
  scorpionApp::registerApps();
}
void
scorpionApp::registerApps()
{
  registerApp(scorpionApp);
}

// External entry point for object registration
extern "C" void
scorpionApp__registerAll(Factory & factory, ActionFactory & action_factory, Syntax & syntax)
{
  scorpionApp::registerAll(factory, action_factory, syntax);
}
void
scorpionApp::registerAll(Factory & factory, ActionFactory & action_factory, Syntax & syntax)
{
  Registry::registerObjectsTo(factory, {"scorpionApp"});
  Registry::registerActionsTo(action_factory, {"scorpionApp"});

  ModulesApp::registerAll(factory, action_factory, syntax);
}
