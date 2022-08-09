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
    boundary = 'bottom_right_1 bottom_right_2'
    variable = 'disp_x'
  []
  [hold_b_r_y]
    type = DirichletBC
    value = 0.0
    boundary = 'bottom_right_1 bottom_right_2'
    variable = 'disp_y'
  []
  # [Pressure]
  #   [left_side]
  #     boundary = left_top_1
  #     function = force_cont
  #   []
  # []
  [disp_cont_n]
    type = FunctionDirichletBC
    function = disp_cont_n
    boundary = left_top_2
    variable = disp_y
  []
  [disp_cont_s]
    type = FunctionDirichletBC
    function = disp_cont_n
    boundary = left_top_1
    variable = disp_x
  []
[]
[Functions]
  [force_cont]
    type = PiecewiseLinear
    x = '0 1.0 16.0'
    y = '1 1 1'
  []
  [disp_cont_n]
    type = PiecewiseLinear
    x = '0.0 1.0'
    y = '0.0 0.33'
    extrap = true
  []
  [disp_cont_s]
    type = PiecewiseLinear
    x = '0.0 1.0'
    y = '0.0 -0.33'
    extrap = true
  []
[]
[AuxVariables]
  [damage]
    order = CONSTANT
    family = MONOMIAL
  []
  [proc_id]
    order = CONSTANT
    family = MONOMIAL
  []
[]
[AuxKernels]
  [damage]
    type = MaterialRealAux
    variable = damage
    property = damage_index
    execute_on = TIMESTEP_END
  []
  [proc_id]
    type = ProcessorIDAux
    variable = proc_id
    execute_on = "INITIAL"
  []
[]


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
    use_old_damage=true
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
  []
[]
[Postprocessors]
  [react_y_n]
    type = SidesetReaction
    direction = '0 1 0'
    stress_tensor = stress
    boundary = left_top_2
  []
  [react_y_s]
    type = SidesetReaction
    direction = '-1 0 0'
    stress_tensor = stress
    boundary = left_top_1
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

  dt = 0.0001
  dtmin = 1e-8
  end_time = 0.15
  # timestep_tolerance = 1e-7
[]

[Outputs]
  file_base = mazars/results/new_sys/mazars_local_test
  csv = true
  [exo]
    type = Exodus
    interval = 10
  []
[]
