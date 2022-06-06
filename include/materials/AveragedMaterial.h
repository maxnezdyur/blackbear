/****************************************************************/
/*               DO NOT MODIFY THIS HEADER                      */
/*                       BlackBear                              */
/*                                                              */
/*           (c) 2017 Battelle Energy Alliance, LLC             */
/*                   ALL RIGHTS RESERVED                        */
/*                                                              */
/*          Prepared by Battelle Energy Alliance, LLC           */
/*            Under Contract No. DE-AC07-05ID14517              */
/*            With the U. S. Department of Energy               */
/*                                                              */
/*            See COPYRIGHT for full restrictions               */
/****************************************************************/

#include "ADMaterial.h"
#include "RadiusAverage.h"

#pragma once

class ElementUserObject;

class AveragedMaterial : public Material
{
public:
  static InputParameters validParams();
  AveragedMaterial(const InputParameters & parameters);

protected:
  virtual void computeProperties() override;
  std::string _material_avg_name;
  MaterialProperty<Real> & _mat_avg;

private:
  const RadiusAverage & _ele_uo;
};
