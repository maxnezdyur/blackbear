[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  construct_side_list_from_node_list = true
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmax = 200
    ymax = 200
    nx = 164
    ny = 164
    elem_type = QUAD4
  []
  [node_set]
  type = ExtraNodesetGenerator
  input = gen
  new_boundary = node_pin
  nodes = 0
  []
  [sub1]
    type = SubdomainBoundingBoxGenerator
    input = node_set
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
[]

[Variables]
  [disp_x]
    # order = SECOND
  []
  [disp_y]
    # order = SECOND
  []
[]

[Kernels]
  [sdx]
    type = TotalLagrangianStressDivergence
    variable = disp_x
    component = 0
    large_kinematics = true
  []
  [sdy]
    type = TotalLagrangianStressDivergence
    variable = disp_y
    component = 1
    large_kinematics = true
  []
[]
[BCs]
  [hold_b_r_x]
    type = DirichletBC
    value = 0.0
    boundary = 'bottom'
    variable = 'disp_y'
    preset = false
  []
  [hold_b_r_y]
    type = DirichletBC
    value = 0.0
    boundary = 'node_pin'
    variable = 'disp_x'
    preset = false
  []
  [disp_cont_n]
    type = FunctionDirichletBC
    function = disp_cont_n
    boundary = top
    variable = disp_y
  []
[]
[Functions]
  [disp_cont_n]
    type = PiecewiseLinear
    x = '0.0 1.0'
    y = '0.0 0.05'
    extrap = true
  []
[]
[AuxVariables]
  [damage]
    order = CONSTANT
    family = MONOMIAL
  []
  [local_damage]
    order = CONSTANT
    family = MONOMIAL
  []
  [proc_id]
    order = CONSTANT
    family = MONOMIAL
  []
[]
[AuxKernels]
  # [nonlocal_damage]
  #   type = MaterialRealAux
  #   variable = damage
  #   property = nonlocal_damage
  #   execute_on = timestep_end
  # []
  [local_damage]
    type = MaterialRealAux
    variable = local_damage
    property = local_damage
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
  [maz_local]
    type = MazarsDamage
    tensile_strength = 5
    a_t = 1.0
    a_c = 1.2
    b_t = 15000
    b_c = 1500
    residual_stiffness_fraction = 1e-04
    use_displaced_mesh = true
    damage_index_name = local_damage
    use_old_damage = true
  []
  [lang_strain]
    type = ComputeLagrangianStrain
    large_kinematics = true
  []
  [stress]
    type = ComputeDamageStress
    damage_model = maz_local
    #block = 2
  []
  [new_system]
    type = ComputeLagrangianWrappedStress
    use_displaced_mesh = true
    #block = 2
  []
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    poissons_ratio = 0.2
    use_displaced_mesh = true
    youngs_modulus = 30000
    block=0
  []
[]
[Postprocessors]
  [react_y_n]
    type = SidesetReaction
    direction = '0 1 0'
    stress_tensor = stress
    boundary = bottom
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

  dt = 0.001
  dtmin = 1e-8
  end_time = 0.7
  # timestep_tolerance = 1e-7
[]

[Outputs]
  file_base = mazars/results/new_sys/mazars_local_ele_2
  csv = true
  [exo]
    type = Exodus
    interval = 10
  []
[]

