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

[Kernels]
  [TensorMechanics]
  strain = FINITE
  use_displaced_mesh = true
  block = 2
  incremental = false
  []
[]

[AuxVariables]
  [strain_xx]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []
  [strain_yy]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []
  [strain_xy]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []

  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []

  [stress_xy]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []

  [damage_index]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []
[]

[AuxKernels]
  [strain_xx]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_xx
    index_i = 0
    index_j = 0
    execute_on = timestep_end
    block = 2 
  []
  [strain_yy]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_yy
    index_i = 1
    index_j = 1
    execute_on = timestep_end
    block = 2 
  []

  [strain_xy]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_xy
    index_i = 0
    index_j = 1
    execute_on = timestep_end
    block = 2 
  []

  [stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
    execute_on = timestep_end
    block = 2 
  []
  [stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
    execute_on = timestep_end
    block = 2 
  []

  [stress_xy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xy
    index_i = 0
    index_j = 1
    execute_on = timestep_end
    block = 2 
  []

  [damage_index]
    type = MaterialRealAux
    variable = damage_index
    property = damage_index
    execute_on = timestep_end
    block = 2 
  []
[]

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
    x = '0 0.1'
    y = '0 0.1'
  []
  [pull_rev]
    type = PiecewiseLinear
    x = '0 0.1'
    y = '0 -0.1'
  []
[]

[Materials]
  [strain]
    type = ComputeFiniteStrain
    block = 2
  []

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

[Postprocessors]
  [damage_index]
    type = ElementAverageValue
    variable = damage_index
    block = 2
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  automatic_scaling = true
  l_max_its = 2
  l_tol = 1e-3
  nl_max_its = 10
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-8


  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  line_search = "cp"
  end_time = 0.0375
  dt = 0.1
[]

[Outputs]
  exodus = true
  file_base = "self/data/plate_circle"
  console = true
  csv = true

[]
