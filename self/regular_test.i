[GlobalParams]
  displacements = 'disp_x disp_y'
[]
[Problem]
  kernel_coverage_check = false
[]

[Variables]
  [disp_x]
  block = 2
  order= second
  []
  [disp_y]
  block = 2
  order= second
  []
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 11
    ny = 11
    # subdomain_ids = 2
    elem_type = quad8
  []
 [subdomain_id]
    type = ElementSubdomainIDGenerator
    input = corner_node
    subdomain_ids = '
    2 2 2 2 2 1 2 2 2 2 2
    2 2 2 2 2 1 2 2 2 2 2  
    2 2 2 2 2 2 2 2 2 2 2
    2 2 2 2 2 2 2 2 2 2 2   
    2 2 2 2 2 2 2 2 2 2 2
    2 2 2 2 2 2 2 2 2 2 2
    2 2 2 2 2 2 2 2 2 2 2
    2 2 2 2 2 2 2 2 2 2 2
    2 2 2 2 2 2 2 2 2 2 2
    2 2 2 2 2 1 2 2 2 2 2 
    2 2 2 2 2 1 2 2 2 2 2'
  []
  [./corner_node]
    type = ExtraNodesetGenerator
    new_boundary = top_right
    nodes = 0
    input = gen
  [../]
  # [refine]
  #   type = RefineBlockGenerator
  #   input = subdomain_id
  #   block = '2'
  #   refinement = '2'
  #   enable_neighbor_refinement = false
  # []
[]

[Modules/TensorMechanics/Master]
  [all]
    generate_output = 'strain_xx strain_yy strain_zz strain_xy strain_yz strain_xz
                       stress_xx stress_yy stress_zz stress_xy stress_yz stress_xz'
    add_variables = true
       incremental = true
    block = 2
    strain=FINITE
  []
[]

[AuxVariables]
  [damage_index]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []
  [./min]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [damage_average]
  order = CONSTANT
  family = MONOMIAL
  block=2
  []
  [creep_strain_xx]
    order = CONSTANT
    family = MONOMIAL
    block=2
  []
    [omega]
    order = CONSTANT
    family = MONOMIAL
    block = 2
  []
[]

[AuxKernels]
  [damage_local]
    type = MaterialRealAux
    variable = damage_index
    property = damage_index
    execute_on = timestep_end
    block = 2 
  []
    [omega]
    type = MaterialRealAux
    variable = omega
    property = omega
    execute_on = timestep_end
    block = 2 
  []
  # [damage_avg]
  # type = MaterialRealAux
  # variable = damage_average
  # property = damage_index
  # execute_on = timestep_end
  # block = 2
  # []
  [creep_strain_xx]
    type = RankTwoAux
    variable = creep_strain_xx
    rank_two_tensor = creep_strain
    index_j = 0
    index_i = 0
    execute_on = timestep_end
    block=2
  []
[]

[BCs]
  # [fx]
  #   type = DirichletBC
  #   variable = disp_x
  #   boundary =bottom
  #   value = 0.0
  # []
   [fx2]
    type = DirichletBC
    variable = disp_y
    boundary =top_right
    value = 0.0
  []
  # [fx2]
  #   type = DirichletBC
  #   variable = disp_x
  #   boundary = top
  #   value = 0.0
  # []

  [fy]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = left
    function = pull_rev
  []
  [fy2]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = right
    function = pull
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



[Materials]
  [dummy_material]
    type = GenericConstantMaterial
    prop_names = 'dummy'
    prop_values = '0.0'
	  block = 1
  []

# [average_mat]
#   type = AveragedMaterial
#   ele_uo = "ele_avg"
#   material_average_name = "material_average"
#   block = 2
# []
[damage]
    type = SteelCreepDamageOh
    epsilon_f = 0.01
    creep_strain_name = creep_strain
    reduction_factor = 1.0e3
    use_old_damage = true
    creep_law_exponent = 10.0
    reduction_damage_threshold = 0.9
    block = 2
    damage_index_name = damage_index
    maximum_damage_increment = 0.9999
  []

  [radial_return_stress]
    type = ComputeMultipleInelasticStress
    inelastic_models = 'powerlawcrp'
    damage_model = damage
    block = 2
  []
  [powerlawcrp]
    type = PowerLawCreepStressUpdate
    coefficient = 3.125e-21
    n_exponent = 4.0
    m_exponent = 0.0
    activation_energy = 0.0
    block=2
  []
  [elasticity]
    type = ComputeIsotropicElasticityTensor
    poissons_ratio = 0.2
    youngs_modulus = 10e9
    block=2
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

  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu    superlu_dist'
  automatic_scaling = true
  line_search = 'bt'
  end_time = 30.0
  dt = 1.0
[]
[Outputs]
  exodus = true
  file_base = "self/data/reg"
[]
