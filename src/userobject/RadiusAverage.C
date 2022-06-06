//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

// MOOSE includes
#include "RadiusAverage.h"

#include "libmesh/quadrature.h"
registerMooseObject("MooseApp", RadiusAverage);

InputParameters
RadiusAverage::validParams()
{
  InputParameters params = ElementUserObject::validParams();
  params.addClassDescription("Performs a spatial average");
  params.addRequiredCoupledVar("variable", "The name of the variable that this object operates on");
  params.addRequiredParam<Real>("radius",
                                "The name of the radius variable that this object operates on");
  return params;
}

RadiusAverage::RadiusAverage(const InputParameters & parameters)
  : ElementUserObject(parameters),
    MooseVariableInterface<Real>(this,
                                 false,
                                 "variable",
                                 Moose::VarKindType::VAR_ANY,
                                 Moose::VarFieldType::VAR_FIELD_STANDARD),
    _qp(0),
    _u(coupledValue("variable")),
    _kdtree(nullptr),
    _radius(this->template getParam<Real>("radius"))
{
  addMooseVariableDependency(&mooseVariableField());
}

void
RadiusAverage::initialize()
{
  _qp_locs.clear();
  _elem_qp.clear();
  _contrib.clear();
  _vol.clear();
  _elem_to_qp.clear();
}

void
RadiusAverage::execute()
{
  computeQPs();
}

void
RadiusAverage::computeQPs()
{
  for (_qp = 0; _qp < _qrule->n_points(); _qp++)
    computeQp();
}

void
RadiusAverage::computeQp()
{
  _qp_locs.push_back(_q_point[_qp]);
  _elem_qp.push_back(std::make_pair(_current_elem->id(), _qp));
  _contrib.push_back(_u[_qp] * _JxW[_qp] * _coord[_qp]);
  _vol.push_back(_JxW[_qp] * _coord[_qp]);
  _elem_to_qp[_current_elem->id()].push_back(0);
}
void
RadiusAverage::finalize()
{
  // ! This is not how to use finalize but works for now
  computeContributions();
  _elem_to_qp_old = _elem_to_qp;
}
void
RadiusAverage::computeContributions()
{
  _kdtree = std::unique_ptr<KDTree>(new KDTree(_qp_locs, _mesh.getMaxLeafSize()));
  int index = 0;
  for (Point & p : _qp_locs)
  {
    computeContribution(p, index);
    index++;
  }
}

void
RadiusAverage::computeContribution(Point & p, std::size_t index)
{
  std::vector<std::pair<std::size_t, Real>> indices_dist;
  _kdtree->radiusSearch(p, _radius, indices_dist);
  std::pair<std::size_t, std::size_t> elem_qp = _elem_qp[index];
  Real sum = 0;
  for (const auto & index_dist : indices_dist)
  {
    const std::size_t index = index_dist.first;
    const Real dist = index_dist.second; // distance will be used later just pure avg now
    const Real contribution = _contrib[index] * computeWeight(dist);
    sum += _vol[index] * computeWeight(dist);
    _elem_to_qp.at(elem_qp.first)[elem_qp.second] += contribution;
  }
  _elem_to_qp.at(elem_qp.first)[elem_qp.second] /= sum;
}

Real
RadiusAverage::getAverage(std::size_t elem_id, std::size_t qp) const
{
  // return _elem_to_qp.at(elem_id)[qp];
  // find the element or return 0
  if (_elem_to_qp_old.find(elem_id) == _elem_to_qp.end())
    return 0;
  return _elem_to_qp_old.at(elem_id)[qp];
}

Real
RadiusAverage::computeWeight(const Real & dist)
{
  return 1 - Utility::pow<2>(dist / (0.75 * 2 * _radius));
}
