[Problem]
  kernel_coverage_check = false
[]

[Mesh]
  [gen_mesh]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 100
    ny = 50
    xmin = 0
    ymin = 0
    xmax = 2.5E-3
    ymax = 1.2E-3
  []

  [solid_domain]
    input = gen_mesh
    type = SubdomainBoundingBoxGenerator
    bottom_left = '0 0 0'
    top_right = ' 2.5E-3 0.5E-3 0'
    block_id = 1
  []

  [powder_domain]
    input = solid_domain
    type = SubdomainBoundingBoxGenerator
    bottom_left = '0 0.5E-3 0'
    top_right = '2.5E-3 0.6E-3 0'
    block_id = 2
  []

  [gas_domain]
    input = powder_domain
    type = SubdomainBoundingBoxGenerator
    bottom_left = '0 0.6E-3 0'
    top_right = '2.5E-3 1.2E-3 0'
    block_id = 3
  []

  [sidesets_top]
    input = gas_domain
    type = SideSetsAroundSubdomainGenerator
    normal = '0 1 0'
    block = 2
    new_boundary = 'top'
  []
[]

[Variables]
  [u]
    initial_condition = -1e5
    family = LAGRANGE
    block = '1 2'
  []
[]

[Kernels]
  [dummy]
    type = NullKernel
    variable = u
  []
[]

[UserObjects]
  [activated_elem_sd2]
    type = CoupledVarThresholdElementSubdomainModifier
    coupled_var = path_var_sd2
    criterion_type = ABOVE
    threshold = 0
    subdomain_id = 2
    moving_boundary_name = top_powder
    execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
    apply_initial_conditions = true
    block = 3
  []
[]

[AuxVariables]
  [path_var_sd2]
  []
[]

[AuxKernels]
  [path_elem_sd2]
    type = ParsedAux
    variable = path_var_sd2
    function = 't+0.6e-3-y'
    use_xyzt = true
    execute_on = 'TIMESTEP_BEGIN'
  []
[]

[Executioner]
  type = Transient
  dt = 1e-4
  end_time = 1e-3
[]

[Outputs]
  exodus = true
[]