[GlobalParams]
  displacements = 'disp_x disp_y'
[]
[Problem]
  kernel_coverage_check = false
[]

[Variables]
  [disp_x]
  block = 2
  []
  [disp_y]
  block = 2
  []
[]

[Mesh]
  [ccmg]
    type = ConcentricCircleMeshGenerator
    num_sectors =4
    radii = '0.25'
    rings =  "1 2"
    has_outer_square = on
    preserve_volumes = false
    pitch = 1
    portion = left_half
  []
# [add_element]
#     type = GeneratedMeshGenerator
#     dim = 2
#     subdomain_ids = 3
#     elem_type = 'QUAD4' 

# []
# [combine_mesh]
#    type = MeshCollectionGenerator
#     inputs = 'ccmg add_element'
# []
[]

[Modules/TensorMechanics/Master]
  [all]
    generate_output = 'strain_xx strain_yy strain_zz strain_xy strain_yz strain_xz
                       stress_xx stress_yy stress_zz stress_xy stress_yz stress_xz'
    add_variables = true
    block = 2
  []
[]

[AuxVariables]
  [damage_index]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []
  [damage_avg]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []
      [./min]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [damage_index]
    type = MaterialRealAux
    variable = damage_index
    property = damage_index
    execute_on = timestep_end
    block = 2 
  []
  # [damage_avg]
  #   type = SpatialUserObjectAux
  #   variable = damage_avg
  #   user_object = ele_avg
  #   block = 2
  # []
    [damage_avg]
    type = MaterialRealAuxRadius
    variable = damage_avg
    property = damage_index
    execute_on = timestep_end
    block = 2
  []
    [./min]
    type = ElementLengthAux
    variable = min
    method = min
    execute_on = initial
  [../]
[]
# [UserObjects]
#   [ele_avg]
#     type = NearestRadiusLayeredAverage
#     direction = 'x'
#     num_layers = 1
#     average_radius = 1
#     variable = damage_index
#     execute_on = TIMESTEP_END
#     block = 2
#   []
# []


[BCs]
  [fx]
    type = DirichletBC
    variable = disp_x
    boundary =bottom
    value = 0.0
  []
  [fx2]
    type = DirichletBC
    variable = disp_x
    boundary = top
    value = 0.0
  []

  [fy]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = top
    function = pull
  []
  [fy2]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = bottom
    function = pull_rev
  []
[]

[Functions]
  [pull]
    type = PiecewiseLinear
    x = '0 10000.0'
    y = '0 0.4'
  []
  [pull_rev]
    type = PiecewiseLinear
    x = '0 10000.0'
    y = '0 -0.4'
  []
[]

[UserObjects]
  [kill_element]
    type = CoupledVarThresholdElementSubdomainModifier
    coupled_var = 'damage_index'
    block = 2
    criterion_type = ABOVE
    threshold = 0.5
    subdomain_id = 1
    execute_on = 'INITIAL timestep_begin'
  []
[]
[Materials]
  [stress]
    type = NEMLStress
    model = test_powerdamage
    database = 'damage.xml'
    block = 2
  []
  [dummy_material]
      type = GenericConstantMaterial
    prop_names = 'dummy'
    prop_values = '0.0'
	block = 1
  []
[]

[Preconditioning]
  [pc]
    type = SMP
    full = True
  []
[]

# [Postprocessors]
#   [damage_index]
#     type = ElementAverageValue
#     variable = damage_index
#     block = 2
#   []
# []

[Executioner]
  type = Transient
  solve_type = 'NEWTON'

  l_max_its = 5
  l_tol = 1e-14
  nl_max_its = 10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  petsc_options = '-snes_converged_reason -ksp_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  automatic_scaling = true

  end_time = 900.0
  dt = 100.0
[]
[Outputs]
  exodus = true
  file_base = "self/data/plate_circle"
[]
