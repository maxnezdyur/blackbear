//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "MaterialRealAuxRadius.h"
#include "KDTree.h"

registerMooseObject("MooseApp", MaterialRealAuxRadius);
registerMooseObject("MooseApp", ADMaterialRealAuxRadius);

template <bool is_ad>
InputParameters
MaterialRealAuxRadiusTempl<is_ad>::validParams()
{
  InputParameters params = MaterialAuxBaseTempl<Real, is_ad>::validParams();
  params.addClassDescription("Outputs element volume-averaged material properties");
  return params;
}

template <bool is_ad>
MaterialRealAuxRadiusTempl<is_ad>::MaterialRealAuxRadiusTempl(const InputParameters & parameters)
  : MaterialAuxBaseTempl<Real, is_ad>(parameters)
{
}

template <bool is_ad>
Real
MaterialRealAuxRadiusTempl<is_ad>::getRealValue()
{
  std::vector<Point> ele_centers;
  for (const auto & ele : *this->_mesh.getActiveLocalElementRange())
  {
    ele_centers.push_back(ele->centroid());
  }
  KDTree kd_tree(ele_centers, this->_mesh.getMaxLeafSize());
  std::vector<std::pair<std::size_t, Real>> indices_dist;
  Point curr_ele_center = this->_current_elem->centroid();
  kd_tree.radiusSearch(curr_ele_center, 0.5, indices_dist);
  // _prop and _qp are members of a dependent template so they need to be qualified with this->
  return MetaPhysicL::raw_value(this->_prop[this->_qp]);
}

template class MaterialRealAuxRadiusTempl<false>;
template class MaterialRealAuxRadiusTempl<true>;
