//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

// MOOSE includes
#include "ElementUserObject.h"
#include "KDTree.h"
#include "MooseUtils.h"
#include <unordered_map>
#include <vector>

/**
 * This postprocessor computes a spatial average of the specified
 * variable.
 */
class RadiusAverage : public ElementUserObject, public MooseVariableInterface<Real>
{
public:
  static InputParameters validParams();

  RadiusAverage(const InputParameters & parameters);

  virtual void finalize() override;
  virtual void initialize() override;
  virtual void execute() override;
  virtual void threadJoin(const UserObject & uo) override{};
  virtual std::vector<Real> getAverage(std::size_t elem_id) const;

protected:
  virtual void computeQp();
  virtual void computeQPs();
  virtual void computeContribution(Point & p, std::size_t index);
  virtual Real computeWeight(const Real & dist);
  virtual void computeContributions();
  unsigned int _qp;

  /// Holds the solution at current quadrature points
  const VariableValue & _u;
  std::unique_ptr<KDTree> _kdtree;
  std::unordered_map<dof_id_type, std::vector<Real>> _elem_to_qp;
  std::unordered_map<dof_id_type, std::vector<Real>> _elem_to_qp_old;
  std::vector<Point> _qp_locs;
  std::vector<std::pair<std::size_t, std::size_t>> _elem_qp;
  std::vector<Real> _contrib;
  std::vector<Real> _vol;

  double _radius;
};
