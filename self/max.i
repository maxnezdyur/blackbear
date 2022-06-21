[Mesh]
  [generated_mesh]
    type = FileMeshGenerator
    file = max.e
  []
  [bc_fix]
    type = SideSetsFromPointsGenerator
    new_boundary = 'bc_fix'
    input = 'generated_mesh'
    points = '50.0 0.0 0.0'
  []
  # TODO
  # [node_ids]
  #   type = SideSetsFromPointsGenerator
  #   new_boundary = 'bc_node'
  #   input = 'generated_mesh'
  #   points = '50.0 0.0 -1.2'
  # []
  # [node_ids_1]
  #   type = SideSetsFromPointsGenerator
  #   new_boundary = 'bc_node_1'
  #   input = 'node_ids'
  #   points = '37.5218 0.0 -1.2'
  # []
  second_order = false

[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  volumetric_locking_correction = true
  order = FIRST
  family = LAGRANGE
[]

[Problem]
  kernel_coverage_check = false
  material_coverage_check = false
[]

[Variables]
[]

[AuxVariables]
  [saved_x]
  []
  [saved_y]
  []
  [damage_index]
    order = CONSTANT
    family = MONOMIAL
  []
  [omega]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [damage_index]
    type = ADMaterialRealAux
    variable = damage_index
    property = damage_index
    execute_on = timestep_end
  []
  [omega]
    type = ADMaterialRealAux
    variable = omega
    property = omega
    execute_on = timestep_end
  []
[]

[Functions]
  [push_up]
    type = ParsedFunction
    # 50 stands for specimen width: 21000/50 ~ 420 (70.08 in 3D)
    # 44
    value = 'if(t < 0.01, 70.0*t*100, 70.0)'
  []
[]

[Modules/TensorMechanics/Master]
  [all]
    add_variables = true
    strain = FINITE
    use_automatic_differentiation = true
    generate_output = 'stress_xx stress_xy stress_xz stress_yy vonmises_stress creep_strain_xx '
                      'creep_strain_yy'
    save_in = 'saved_x saved_y'
  []
[]

[BCs]
  [Pressure]
    [Side1]
      boundary = 24
      function = push_up
    []
  []
  [botx]
    type = ADDirichletBC
    variable = disp_x
    boundary = 'bc_fix'
    value = 0.0
  []
  [boty]
    type = ADDirichletBC
    variable = disp_y
    boundary = 53
    value = 0.0
  []
[]

[Materials]
  [damage]
    type = ADSteelCreepDamageOh
    epsilon_f =  0.01
    creep_strain_name = creep_strain
    reduction_factor = 1.0e3
    use_old_damage = true
    creep_law_exponent = 12.5
    reduction_damage_threshold = 0.7
  []
  [radial_return_stress]
    type = ADComputeMultipleInelasticStress
    inelastic_models = 'powerlawcrp isoplas'
    damage_model = damage
    # max_iterations = 300
    # relative_tolerance = 1e-03
    # absolute_tolerance = 1e-07
  []

   [powerlawcrp]
     type = ADPowerLawCreepStressUpdate
     coefficient = 3.125e-21
     n_exponent = 4.0
     m_exponent = 0.0
     activation_energy = 0.0
     max_inelastic_increment = 100000.0
   []
  [elasticity]
    type = ADComputeIsotropicElasticityTensor
    poissons_ratio = 0.3
    youngs_modulus = 210000 
  []
  [isoplas]
    type = ADIsotropicPlasticityStressUpdate
    yield_stress = 350
    hardening_constant = 0
    absolute_tolerance = 1e-11
    relative_tolerance = 1e-9
    max_inelastic_increment = 1000.0
  []
[]

[Postprocessors]
  [nl_its]
    type = NumNonlinearIterations
  []
  [lin_its]
    type = NumLinearIterations
  []
  [react_y]
    type = NodalSum
    variable = saved_y
    boundary = 53
  []
  [matl_ts_min]
    type = MaterialTimeStepPostprocessor
  []

  [lld]
    type = NodalVariableValue
    variable = 'disp_y'
    nodeid = 2045
  []
  [lld_left]
    type = NodalVariableValue
    variable = 'disp_y'
    nodeid = 721 # 2131 # 583
  []
  [lld_right]
    type = NodalVariableValue
    variable = 'disp_y'
    nodeid = 792 # 2344 # 653
  []
  [vm_stress_tip]
    type = ElementalVariableValue
    variable = 'vonmises_stress'
    elementid = 3044 # 2609 # 2608
  []
[]

[VectorPostprocessors]
  [crack]
    type = LineValueSampler
    variable = 'omega'
    start_point = '26.44 0.005 0.0'
    end_point = '48.0 0.005 0.0'
    num_points = 1000
    sort_by = x
  []
[]

[Debug]
  show_var_residual_norms = true
[]

# [UserObjects]
#   [delete_damaged]
#     type = CoupledVarThresholdElementSubdomainModifier
#     coupled_var = 'omega'
#     block = 1
#     criterion_type = ABOVE
#     threshold = 0.7
#     subdomain_id = 999
#     moving_boundary_name = 999
#     execute_on = 'INITIAL TIMESTEP_BEGIN'
#   []
# []

[Executioner]
  type = Transient
  solve_type = 'NEWTON'

  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu    superlu_dist'
  line_search = 'bt'

  l_max_its = 15
  nl_max_its = 20
  dtmin = 0.00001
  nl_rel_tol = 1e-9
  nl_abs_tol = 6e-5 # 6 if no friction
  l_tol = 1e-3
  start_time = 0.0
  end_time = 5000

  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 60
    iteration_window = 6
    growth_factor = 1.2
    cutback_factor = 0.5
    dt = 0.0001
    time_t = '0  0.008 0.01 15.0 1000000000'
    time_dt = '0.00002 0.00002 0.025 1.0 1.0'
    timestep_limiting_postprocessor = matl_ts_min
  []
  dtmax = 1.0

#  [Predictor]
#    type = SimplePredictor
#    scale = 1.0
#  []
[]

[Outputs]
  exodus = true
    file_base = "self/data/max"
  [csv]
    type = CSV
    interval = 1
  []
  [out]
    type = Checkpoint
    interval = 10
    num_files = 2
  []
  print_linear_residuals = true
  perf_graph = true
  [console]
    type = Console
    max_rows = 5
  []
[]

[UserObjects]
  # [terminator_creep]
  #   type = Terminator
  #   expression = 'time_step_size > 3.0'
  #   fail_mode = SOFT
  #   execute_on = INITIAL
  # []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  
  []
[]
