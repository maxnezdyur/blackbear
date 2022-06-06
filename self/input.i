[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 4
    ny = 4
  []
  [block1]
    type = SubdomainBoundingBoxGenerator
    input = 'gen'
    block_id = 1
    bottom_left = '0 0.5 0'
    top_right = '1 1 1'
  []
  [block2]
    type = SubdomainBoundingBoxGenerator
    input = 'block1'
    block_id = 2
    bottom_left = '0 0 0'
    top_right = '1 0.5 1'
  []
[]

[Problem]
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
  group_variables = 'disp_x disp_y'
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Modules/TensorMechanics/Master]
  generate_output = 'stress_xx stress_yy stress_xy
                     strain_xx strain_yy strain_xy
                     vonmises_stress hydrostatic_stress
                     elastic_strain_xx elastic_strain_yy'
  [conglomerates]
    block = '1 2'
    strain = FINITE
    temperature = u
    add_variables = true
    eigenstrain_names = 'thermal_expansion'
    save_in = 'resid_x resid_y'
    volumetric_locking_correction = true
    planar_formulation = WEAK_PLANE_STRESS
    out_of_plane_strain = strain_zz
    extra_vector_tags = 'ref'
  []
[]

[Variables]
  [u]
    order = FIRST
    family = LAGRANGE
  []
  [strain_zz]
    block = '1 2'
  []
[]

[Kernels]
  [diffusion]
    type = 'Diffusion'
    variable = u
    extra_vector_tags = 'ref'
  []
  [timederivative]
    type = TimeDerivative
    variable = u
    extra_vector_tags = 'ref'
  []
[]

[AuxVariables]
  [resid_x]
  []
  [resid_y]
  []
[]

[BCs]
  [top_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'top bottom'
    value = 0
  []
  [top_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'top bottom'
    value = 0
  []
  [right]
    type = FunctionDirichletBC
    function = 't'
    variable = u
    boundary = 'right'
  []
  [left]
    type = FunctionDirichletBC
    function = '0'
    variable = u
    boundary = 'left'
  []
[]

[Materials]
  [elastic_stress_matrix]
    type = ComputeFiniteStrainElasticStress
    block = '1 2'
  []
  [elasticity_tensor_matrix]
    type = ComputeIsotropicElasticityTensor
    block = '1 2'
    youngs_modulus = 1e6
    poissons_ratio = 0.3
  []
  [thermal_strain_matrix]
    type = ComputeThermalExpansionEigenstrain
     block = '1 2'
    temperature = u
    thermal_expansion_coeff = 1e-6
    stress_free_temperature = 23.0
    eigenstrain_name = thermal_expansion
  []
[]

[UserObjects]
  [domainModifier]
    type = CoupledVarThresholdElementSubdomainModifier
    coupled_var = 'u'
    block = 2
    criterion_type = BELOW
    threshold = 0.5
    subdomain_id = 1
    moving_boundary_name = 'moving_boundary'
    execute_on = 'TIMESTEP_BEGIN'
    # execute_on = 'TIMESTEP_END' # TIMESTEP_END does not provide variable values .e file
    apply_initial_conditions=false
  []
[]

[Postprocessors]
  [VonMisesStress]
    type = PointValue
    variable = vonmises_stress
    point = '0.5 0.99 0'
  []
[]

[Executioner]
  type = Transient
  dt = 1
  end_time = 2
  nl_max_its = 20
  l_max_its = 10
  nl_abs_tol = 1e-5
  nl_rel_tol = 1e-9
[]

[Outputs]
  exodus = true
  csv = true
[]