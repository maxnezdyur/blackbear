[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = true
  order = FIRST
  family = LAGRANGE
[]
[Problem]
  kernel_coverage_check = false
  extra_tag_vectors = 'ref'
[]

[Variables]
[]

[Mesh]
  [gen]
    type = FileMeshGenerator
    file = /Users/nezdmn-mac/projects/blackbear/self/notch/notched_plate_refined.e
  []
  [./corner_node]
    type = ExtraNodesetGenerator
    new_boundary = top_right
    nodes = 0
    input = gen
  [../]
[]

[Modules/TensorMechanics/Master]
  [all]
    # generate_output = 'strain_xx strain_yy strain_zz strain_xy strain_yz strain_xz
    #  stress_xx stress_yy stress_zz stress_xy stress_yz stress_xz'
    add_variables = true
    incremental = true
    block = 1
    use_automatic_differentiation = true
    strain = FINITE
    extra_vector_tags = 'ref'
  []
[]

[AuxVariables]
  [damage_index_local]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []
  [min]
    order = CONSTANT
    family = MONOMIAL
  []
  [damage_average]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []
  [omega]
    order = CONSTANT
    family = MONOMIAL
    block = 1
  []
  [saved_x]
    # order = SECOND
  []
  [saved_y]
    # order = SECOND
  []
  [proc_id]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [damage_local]
    type = ADMaterialRealAux
    variable = damage_index_local
    property = damage_index_local
    execute_on = timestep_end
    block = 1
  []
  [omega]
    type = ADMaterialRealAux
    variable = omega
    property = omega
    execute_on = timestep_end
    block = 1
  []
  [damage_avg]
    type = ADMaterialRealAux
    variable = damage_average
    property = damage_index
    execute_on = timestep_end
    block = 1
  []

  [saved_x]
    type = TagVectorAux
    vector_tag = 'ref'
    v = 'disp_x'
    variable = 'saved_x'
  []
  [saved_y]
    type = TagVectorAux
    vector_tag = 'ref'
    v = 'disp_y'
    variable = 'saved_y'
  []
  [proc_id]
    type = ProcessorIDAux
    variable = proc_id
    execute_on = "INITIAL"
  []
[]

[BCs]
  [fx2]
    type = ADDirichletBC
    variable = disp_x
    boundary = top_right
    value = 0.0
  []
  [fy]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = 1
    function = pull_rev
  []
  [fy2]
    type = ADFunctionDirichletBC
    variable = disp_y
    boundary = 2
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
  # [dummy_material]
  #   type = ADGenericConstantMaterial 
  #   prop_names = 'dummy'
  #   prop_values = '0.0'
  #   block = 1
  # []
  [converter_to_ad]
    type = MaterialADConverter
    ad_props_in = damage_index_local
    reg_props_out = damage_index_local_out
    block = 1
  []
  [damage]
    type = ADSteelCreepDamageOhAvg
    epsilon_f = 0.01
    creep_strain_name = creep_strain
    reduction_factor = 1.0e3
    use_old_damage = false
    creep_law_exponent = 10.0
    reduction_damage_threshold = 0.9
    average = "ele_avg"
    block = 1
    damage_index_name = damage_index
    #maximum_damage_increment = 0.9999
  []

  [radial_return_stress]
    type = ADComputeMultipleInelasticStress
    inelastic_models = 'powerlawcrp'
    damage_model = damage
    block = 1
  []
  [powerlawcrp]
    type = ADPowerLawCreepStressUpdate
    coefficient = 3.125e-21
    n_exponent = 4.0
    m_exponent = 0.0
    activation_energy = 0.0
    block = 1
  []
  [elasticity]
    type = ADComputeIsotropicElasticityTensor
    poissons_ratio = 0.2
    youngs_modulus = 10e9
    block = 1
  []
[]
[UserObjects]
  # [kill_element]
  #   type = CoupledVarThresholdElementSubdomainModifier
  #   coupled_var = 'damage_index'
  #   block = 1
  #   criterion_type = ABOVE
  #   threshold = 0.5
  #   subdomain_id = 1
  #   execute_on = 'INITIAL timestep_begin'
  # []
  [ele_avg]
    type = RadialAverage
    material_name = damage_index_local_out
    execute_on = "timestep_end"
    block = 1
    r_cut = 1.0
    # force_preic =
    # force_preaux = true
  []
[]
[Preconditioning]
  [pc]
    type = SMP
    full = True
  []
[]

[Postprocessors]
  #[reaction_force_x]
  #type = ADSidesetReaction
  #direction = '1 0 0'
  #stress_tensor = "stress"
  #boundary = right
  #block = 1
  #[]
  # [react_x]
  #   type = NodalSum
  #   variable = saved_x
  #   boundary = 1
  # []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'

  l_max_its = 20
  l_tol = 1e-14
  nl_max_its = 30
  nl_rel_tol = 1e-7
  nl_abs_tol = 1e-8

  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu    superlu_dist'
  # automatic_scaling = true
  line_search = 'bt'
  end_time = 70.0
  dt = 0.001
[]
[Outputs]
  # exodus = true
  [Exodus]
    file_base = "self/notch/data/avg"
    type = Exodus
    append_date = true
    interval = 1000
    # output_material_properties = true
  []
  csv = true
[]
