[GlobalParams]
  displacements = 'disp_x disp_y'
[]
[Problem]
  kernel_coverage_check = false
[]

[Variables]
  [disp_x]
  block = 1
  []
  [disp_y]
  block = 1
  []

[]

[Mesh]
[exo]
  type = FileMeshGenerator
  file = "plate_hole.e"
[]
[add_element]
    type = GeneratedMeshGenerator
    dim = 2
    subdomain_ids = 3
    elem_type = 'Tri3' 
[]
[combine_mesh]
   type = MeshCollectionGenerator
    inputs = 'exo add_element'
[]
[]

[Kernels]
  [TensorMechanics]
  strain = FINITE
  use_displaced_mesh = true
  block = 1
  incremental = false
  []
[]

[AuxVariables]
  [strain_xx]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []
  [strain_yy]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []
  [strain_xy]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []

  [stress_xx]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []
  [stress_yy]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []

  [stress_xy]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []

  [damage_index]
    order = CONSTANT
    family = MONOMIAL
    block = 1
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
    block = 1 
  []
  [strain_yy]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_yy
    index_i = 1
    index_j = 1
    execute_on = timestep_end
    block = 1 
  []

  [strain_xy]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_xy
    index_i = 0
    index_j = 1
    execute_on = timestep_end
    block = 1 
  []

  [stress_xx]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xx
    index_i = 0
    index_j = 0
    execute_on = timestep_end
    block = 1 
  []
  [stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 1
    index_j = 1
    execute_on = timestep_end
    block = 1 
  []

  [stress_xy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_xy
    index_i = 0
    index_j = 1
    execute_on = timestep_end
    block = 1 
  []

  [damage_index]
    type = MaterialRealAux
    variable = damage_index
    property = damage_index
    execute_on = timestep_end
    block = 1 
  []
[]

[BCs]
  [fx]
    type = DirichletBC
    variable = disp_x
    boundary =1
    value = 0.0
  []
  [fx2]
    type = DirichletBC
    variable = disp_x
    boundary =2
    value = 0.0
  []

  [fy]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = 1
    function = pull_rev
  []
  [fy2]
    type = FunctionDirichletBC
    variable = disp_y
    boundary = 2
    function = pull
  []
[]

[Functions]
  [pull]
    type = PiecewiseLinear
    x = '0 1 2'
    y = '0 0.2 0.5'
  []
  [pull_rev]
    type = PiecewiseLinear
    x = '0 1 2'
    y = '0 -0.2 -0.5'
  []
[]

[UserObjects]
  [kill_element]
    type = CoupledVarThresholdElementSubdomainModifier
    coupled_var = 'damage_index'
    block = 1
    criterion_type = ABOVE
    threshold = 0.0001
    subdomain_id = 3
    execute_on = 'INITIAL timestep_begin'
  []
[]
[Materials]
  [strain]
    type = ComputeFiniteStrain
    block = 1
  []

  [stress]
    type = NEMLStress
    model = test_powerdamage
    database = 'damage.xml'
    block = 1
  []
  [dummy_material]
      type = GenericConstantMaterial
    prop_names = 'dummy'
    prop_values = '0.0'
	block = 3
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
    block = 1
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'

  l_max_its = 2
  l_tol = 1e-3
  nl_max_its = 50
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  petsc_options = '-snes_converged_reason -ksp_converged_reason -snes_linesearch_monitor'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  line_search = "cp"
  end_time = 2.0
  dt = 0.1
[]

[Outputs]
  exodus = true
  file_base = "self/data/plate_circle"
  console = true
  csv = true
[]
