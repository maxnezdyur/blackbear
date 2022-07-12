[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = true
[]
[Problem]
  extra_tag_vectors = 'ref'
[]
[Mesh]
  construct_side_list_from_node_list = true
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmax = 200
    ymax = 200
    nx = 82
    ny = 82
    elem_type = QUAD4
  []
  [sub1]
    type = SubdomainBoundingBoxGenerator
    input = gen
    bottom_left = '0 97.499 0'
    top_right = '25 102.501 0'
    block_id = 1
  []
  [sub2]
    type = SubdomainBoundingBoxGenerator
    input = sub1
    bottom_left = '175 97.499 0'
    top_right = '200 102.501 0'
    block_id = 1
  []
  [del]
    type = BlockDeletionGenerator
    input = sub2
    block = 1
  []
  [ss_1]
    type = BoundingBoxNodeSetGenerator
    input = del
    bottom_left = '-0.1 100 0 '
    top_right = '0.00001 200.1 0'
    new_boundary = left_top_1
  []
  [ss_2]
    type = BoundingBoxNodeSetGenerator
    input = ss_1
    bottom_left = '-0.1 199.9 0 '
    top_right = '200.1 200.1 0'
    new_boundary = left_top_2
  []
  [ss_3]
    type = BoundingBoxNodeSetGenerator
    input = ss_2
    bottom_left = '199.99 -0.001 0 '
    top_right = '200.1 100 0'
    new_boundary = bottom_right_1
  []
  [ss_4]
    type = BoundingBoxNodeSetGenerator
    input = ss_3
    bottom_left = '-0.1 -0.1 0 '
    top_right = '200.1 0.0001 0'
    new_boundary = bottom_right_2
  []
  [subbloc]
    type = SubdomainBoundingBoxGenerator
    bottom_left = '-0.1 50 0'
    top_right = '200.1 150 0'
    block_id = 1
    input = ss_4
  []
  # [refine_inside]
  #   type = RefineBlockGenerator
  #   input = subbloc
  #   refinement = 1
  #   enable_neighbor_refinement = true
  #   block = 1
  # []
[]

[Modules/TensorMechanics/Master]
  [all]
    strain = FINITE
    incremental = true
    add_variables = true
    block = '0 1'
    use_automatic_differentiation = false
    extra_vector_tags = 'ref'
  []
[]
[BCs]
  [hold_b_r_x]
    type = DirichletBC
    value = 0.0
    boundary = 'bottom_right_1 bottom_right_2'
    variable = 'disp_x'
  []
  [hold_b_r_y]
    type = DirichletBC
    value = 0.0
    boundary = 'bottom_right_1 bottom_right_2'
    variable = 'disp_y'
  []
  [Pressure]
    [left_side]
      boundary = left_top_1
      function = force_cont
    []
  []
  [disp_cont]
    type = FunctionDirichletBC
    function = disp_cont
    boundary = left_top_2
    variable = disp_y
  []
[]
[Functions]
  [force_cont]
    type = PiecewiseLinear
    x = '0 1.0 5.0'
    y = '0 150 150'
  []
  [disp_cont]
    type = PiecewiseLinear
    x = '0 1.0 20.0'
    y = '0 0.0 0.2'
  []
[]
[AuxVariables]
  [saved_y]
    # order = SECOND
  []
  [damage]
    order = CONSTANT
    family = MONOMIAL
  []
  [damage_local]
    order = CONSTANT
    family = MONOMIAL
  []
  [proc_id]
    order = CONSTANT
    family = MONOMIAL
  []
[]
[AuxKernels]
  [saved_y]
    type = TagVectorAux
    vector_tag = 'ref'
    v = 'disp_y'
    variable = 'saved_y'
  []
  [damage]
    type = MaterialRealAux
    variable = damage
    property = damage_index
    execute_on = timestep_end
  []
  [damage_local]
    type = MaterialRealAux
    variable = damage_local
    property = damage_index_local
    execute_on = TIMESTEP_END
  []
  [proc_id]
    type = ProcessorIDAux
    variable = proc_id
    execute_on = "INITIAL"
  []
[]
# [Constraints]
#   [x_top]
#     type = EqualValueBoundaryConstraint
#     variable = disp_x
#     secondary = left_top_2
#     penalty = 10e9
#   []
#   [y_left]
#     type = EqualValueBoundaryConstraint
#     variable = disp_y
#     secondary = left_top_1
#     penalty = 10e9
#   []
#   [x_left]
#     type = EqualValueBoundaryConstraint
#     variable = disp_x
#     secondary = left_top_1
#     penalty = 10e9
#   []
# []

[Materials]
  [damage]
    type = MazarsDamageAvg
    tensile_strength = 10
    a_t = 0.98
    a_c = 0.98
    b_t = 220
    b_c = 141
    use_old_damage = false
    average = "ele_avg"
    # strain_base_name = mechanical_strain_reg
  []
  [stress]
    type = ComputeDamageStress
    damage_model = damage
  []
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    poissons_ratio = 0.2
    youngs_modulus = 46000
  []
[]
[Postprocessors]
  [react_y]
    type = SidesetReaction
    direction = '0 1 0'
    stress_tensor = stress
    boundary = left_top_2
  []
[]

[UserObjects]
  [ele_avg]
    type = RadialAverage
    material_name = damage_index_local
    execute_on = "timestep_end"
    block = '0 1'
    r_cut = 5.01
  []
[]
[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu    superlu_dist'
  automatic_scaling = true
  line_search = 'bt'

  l_max_its = 50
  l_tol = 1e-14
  nl_max_its = 20
  nl_rel_tol = 1e-5
  nl_abs_tol = 1e-6

  dt = 0.05
  dtmin = 1e-8
  end_time = 20.0
[]

[Outputs]
  exodus = true
  file_base = mazars/results/mazars_avg/mazars_avg_test
  csv = true
[]
