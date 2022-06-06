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
[]

[Modules/TensorMechanics/Master]
  [all]
    generate_output = 'strain_xx strain_yy strain_zz strain_xy strain_yz strain_xz
                       stress_xx stress_yy stress_zz stress_xy stress_yz stress_xz'
    add_variables = true
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
[]

[AuxKernels]
  [damage_index]
    type = MaterialRealAux
    variable = damage_index
    property = damage_index
    execute_on = timestep_end
    block = 2 
  []
  [damage_avg]
  type = MaterialRealAux
  variable = damage_average
  property = material_average
  execute_on = timestep_end
  block = 2
  []
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
  # [kill_element]
  #   type = CoupledVarThresholdElementSubdomainModifier
  #   coupled_var = 'damage_index'
  #   block = 2
  #   criterion_type = ABOVE
  #   threshold = 0.5
  #   subdomain_id = 1
  #   execute_on = 'INITIAL timestep_begin'
  # []
  [ele_avg]
    type = RadiusAverage
    variable = damage_index
    radius = 0.3
    execute_on = "NONLINEAR INITIAL TIMESTEP_BEGIN"
    block = 2
    force_preic = true
  []
[]

[Materials]
  [dummy_material]
    type = GenericConstantMaterial
    prop_names = 'dummy'
    prop_values = '0.0'
	  block = 1
  []

[average_mat]
  type = AveragedMaterial
  ele_uo = "ele_avg"
  material_average_name = "material_average"
  block = 2
[]
[damage]
    type = SteelCreepDamageOhAvg
    epsilon_f = 0.01
    creep_strain_name = creep_strain
    reduction_factor = 1.0e3
    use_old_damage = true
    creep_law_exponent = 10.0
    block = 2
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
