num_divs = 20

[GlobalParams]
  displacements = 'disp_x disp_y'
  # volumetric_locking_correction = true
[]
[Problem]
  extra_tag_vectors = 'ref'
[]
[Mesh]
  #   construct_side_list_from_node_list = true
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = ${num_divs}
    ny = 1
    elem_type = QUAD4
  []
  [corner_node]
    type = ExtraNodesetGenerator
    new_boundary = 'pinned_node'
    nodes = '0'
    input = gen
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
  [hold_left_x]
    type = DirichletBC
    value = 0.0
    boundary = 'left'
    variable = 'disp_x'
    use_displaced_mesh = true
    preset = false
  []
  [hold_left_y]
    type = DirichletBC
    value = 0.0
    boundary = 'pinned_node'
    variable = 'disp_y'
    use_displaced_mesh = true
    preset = false
  []
  [pull_left]
    type = FunctionDirichletBC
    variable = disp_x
    function = disp_cont
    boundary = right
    use_displaced_mesh = true
    preset = false
  []
[]
[Functions]
  [disp_cont]
    type = PiecewiseLinear
    x = '0.0 1.0'
    y = '0.0 1.0'
    extrap = true
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
  # [saved_y]
  #   type = TagVectorAux
  #   vector_tag = 'ref'
  #   v = 'disp_y'
  #   variable = 'saved_y'
  # []
  [damage]
    type = MaterialRealAux
    variable = damage
    property = damage_index
    execute_on = timestep_end
    #block = 2
  []
  #   [damage_local]
  #     type = MaterialRealAux
  #     variable = damage_local
  #     property = damage_index_local
  #     execute_on = TIMESTEP_END
  #     #block = 2
  #   []
  [proc_id]
    type = ProcessorIDAux
    variable = proc_id
    execute_on = "INITIAL"
    #block = 2
  []
[]

[Materials]
  [damage]
    type = MazarsDamage
    tensile_strength = 5
    # a_t = 0.98
    # a_c = 0.98
    # b_t = 220
    # b_c = 141
    a_t = 1.0
    a_c = 1.2
    b_t = 15000
    b_c = 1500
    use_old_damage = true
    residual_stiffness_fraction = 1e-04
    use_displaced_mesh = true
    # strain_base_name = mechanical_strain_reg
    #block = 2
  []
  [new_system]
    type = ComputeLagrangianWrappedStress
    use_displaced_mesh = true
    #block = 2
  []
  [lang_strain]
    type = ComputeLagrangianStrain
    large_kinematics = true
  []
  [stress]
    type = ComputeDamageStress
    damage_model = damage
    #block = 2
  []
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    poissons_ratio = 0.2
    use_displaced_mesh = true
    youngs_modulus = 30000
  []
  # [undamged]
  #   type = ComputeLagrangianLinearElasticStress
  #   #block = 0
  # []
[]
[Postprocessors]
  [react_y]
    type = SidesetReaction
    direction = '-1 0 0'
    stress_tensor = stress
    boundary = left
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
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6

  dt = 0.0001 #0.001
  dtmin = 1e-8
  end_time = 0.005
[]

[Outputs]
  # exodus = true
  file_base = mazars/results/axial/local_${num_divs}
  csv = true
  [exo]
    type = Exodus
    interval = 1
  []
[]
