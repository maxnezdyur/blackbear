[GlobalParams]
  displacements = 'disp_x disp_y'
[]
[Problem]
  solve = false
[]

[Variables]
   [u]
     [InitialCondition]
      type = ConstantIC
      value = 2
     []
 []
[]
[Kernels]
  [double_u]
    type = StatefulAux
    variable = u
    coupled = u
    block = 1
  []
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    # subdomain_ids = 2
    elem_type = quad4
  []
[]


[AuxVariables]

 [u_avg]
 []
[]

[AuxKernels]

  [u_avg]
    type = RadialGreensAux
    variable = u_avg
    convolution = green1
  [../]
[]



[UserObjects]

  [./green1]
    type = RadialGreensConvolution
    execute_on = TIMESTEP_BEGIN
    v = u
    r_cut = 0.2
    function = 'x * x'
    normalize = true
  [../]
[]


[Executioner]
  type = Transient
  num_steps = 5
[]

[Outputs]
  exodus = true
  file_base = "self/data/avg"
[]
