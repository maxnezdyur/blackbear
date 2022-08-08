[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
  []
[]
[Problem]
  solve = false
  kernel_coverage_check = false
[]

[AuxVariables]
  [non_local_material]
  []
[]

[AuxKernels]
  [non_local]
    type = RadialAverageAux
    average_UO = ele_avg
    variable = non_local_material
  []
[]

[Functions]
  [func]
    type = ParsedFunction
    value = '1+ t'
  []
[]
[Materials]
  [local_material]
    type = GenericFunctionMaterial
    prop_names = local
    prop_values = func
  []
[]

[UserObjects]
  [ele_avg]
    type = RadialAverage
    material_name = local
    execute_on = "timestep_end"
    block = 0
    r_cut = 0.25
  []
[]

[Executioner]
  type = Transient
  end_time = 3
  dt = 1
[]

[Outputs]
  exodus = true
[]
