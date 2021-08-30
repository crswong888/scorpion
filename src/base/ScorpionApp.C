#include "ScorpionApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
ScorpionApp::validParams()
{
  InputParameters params = MooseApp::validParams();

  // Do not use legacy material output, i.e., output properties on INITIAL as well as TIMESTEP_END
  params.set<bool>("use_legacy_material_output") = false;

  return params;
}

ScorpionApp::ScorpionApp(InputParameters parameters) : MooseApp(parameters)
{
  ScorpionApp::registerAll(_factory, _action_factory, _syntax);
}

ScorpionApp::~ScorpionApp() {}

void
ScorpionApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAll(f, af, syntax);
  Registry::registerObjectsTo(f, {"ScorpionApp"});
  Registry::registerActionsTo(af, {"ScorpionApp"});

  /* register custom execute flags, action syntax, etc. here */
  syntax.registerActionSyntax("EmptyAction", "BCs/PresetLSBLCAcceleration");
  syntax.registerActionSyntax("PresetLSBLCAccelerationAction", "BCs/PresetLSBLCAcceleration/*");
}

void
ScorpionApp::registerApps()
{
  registerApp(ScorpionApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
ScorpionApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ScorpionApp::registerAll(f, af, s);
}
extern "C" void
ScorpionApp__registerApps()
{
  ScorpionApp::registerApps();
}
