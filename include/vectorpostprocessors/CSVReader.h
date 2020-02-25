//* This object is from the MOOSE framework and has been modified
//* https://www.mooseframework.org

#pragma once

// MOOSE includes
#include "GeneralVectorPostprocessor.h"
#include "DelimitedFileReader.h"

// Forward declarations
class CSVReader;

template <>
InputParameters validParams<CSVReader>();

class CSVReader : public GeneralVectorPostprocessor
{
public:
  static InputParameters validParams();

  CSVReader(const InputParameters & parameters);
  void virtual initialize() override;
  void virtual execute() override;

protected:
  /// The MOOSE delimited file reader.
  MooseUtils::DelimitedFileReader _csv_reader;

  /// Data vectors, which are stored in a map to allow for late declarations to occur, i.e., it
  /// is possible for the file to change and add new vectors during the simulation.
  std::map<std::string, VectorPostprocessorValue *> _column_data;
};
