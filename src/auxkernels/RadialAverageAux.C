#include "RadialAverageAux.h"

registerMooseObject("BlackBearApp", RadialAverageAux);

InputParameters
RadialAverageAux::validParams()
{
  InputParameters params = AuxKernel::validParams();
  params.addClassDescription("Auxkernel to output averaged material from RadialAverage");
  params.addRequiredParam<UserObjectName>("average", "Radial Average user object");
  return params;
}

RadialAverageAux::RadialAverageAux(const InputParameters & parameters)
  : AuxKernel(parameters),
    _average(this->template getUserObject<RadialAverage>("average").getAverage())
{
}

Real
RadialAverageAux::computeValue()
{
  if (_qp == 0)
    _elem_avg = _average.find(_current_elem->id());
  if (_elem_avg != _average.end())
    return _elem_avg->second[_qp];
  return 0.0;
}
