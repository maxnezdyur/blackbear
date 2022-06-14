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

#include "AveragedMaterial.h"
#include "MooseObjectName.h"
#include "RadiusAverage.h"

// libMesh includes
#include "libmesh/quadrature.h"

registerMooseObject("BlackBearApp", AveragedMaterial);

InputParameters
AveragedMaterial::validParams()
{
  InputParameters params = Material::validParams();
  // params.addRequiredParam<std::string>(
  //     "type", "A string representing the Moose Object that is used to call
  //     this class");

  params.addRequiredParam<UserObjectName>("ele_uo", "The ElementUserObject that is used");
  params.addParam<std::string>("material_average_name",
                               "material_average",
                               "Name of the creep strain material driving damage failure.");
  return params;
}

AveragedMaterial::AveragedMaterial(const InputParameters & parameters)
  : Material(parameters),
    _material_avg_name(parameters.get<std::string>("material_average_name")),
    _mat_avg(declareProperty<Real>(_material_avg_name)),
    _ele_uo(getUserObject<RadiusAverage>("ele_uo"))
{
}

void
AveragedMaterial::computeProperties()
{
  auto ele_data = _ele_uo.getAverage(_current_elem->id());
  for (unsigned int _qp = 0; _qp < _qrule->n_points(); ++_qp)
  {
    _mat_avg[_qp] = ele_data[_qp];
  }
}
