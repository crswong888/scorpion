#include "scorpionApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
scorpionApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy DirichletBC, that is, set DirichletBC default for preset = true
  params.set<bool>("use_legacy_dirichlet_bc") = false;

  params.set<bool>("use_legacy_material_output") = false;

  return params;
}

scorpionApp::scorpionApp(InputParameters parameters) : MooseApp(parameters)
{
  scorpionApp::registerAll(_factory, _action_factory, _syntax);
}

scorpionApp::~scorpionApp() {}

void
scorpionApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAll(f, af, s);
  Registry::registerObjectsTo(f, {"scorpionApp"});
  Registry::registerActionsTo(af, {"scorpionApp"});

  /* register custom execute flags, action syntax, etc. here */
  s.registerActionSyntax("EmptyAction", "BCs/PresetLSBLCAcceleration");
  s.registerActionSyntax("PresetLSBLCAccelerationAction", "BCs/PresetLSBLCAcceleration/*");
}

void
scorpionApp::registerApps()
{
  registerApp(scorpionApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
scorpionApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  scorpionApp::registerAll(f, af, s);
}
extern "C" void
scorpionApp__registerApps()
{
  scorpionApp::registerApps();
}
