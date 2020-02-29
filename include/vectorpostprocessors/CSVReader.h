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

  /// The vector variables storing the data read from the csv
  std::vector<VectorPostprocessorValue &> _column_data;
};
