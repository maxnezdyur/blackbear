[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 3
  ny = 1
  elem_type = QUAD4
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]
[Kernels]
  [TensorMechanics]
    strain = FINITE
    # incremental = true
  []
[]

[AuxVariables]
  [damage_index]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]

  [damage_index]
    type = MaterialRealAux
    variable = damage_index
    property = damage_index
    execute_on = timestep_end
  []
[]

[BCs]
  [symmy]
    type = DirichletBC
    variable = disp_y
    boundary = "left top bottom"
    value = 0
  []
  [symmx]
    type = DirichletBC
    variable = disp_x
    boundary = left
    value = 0
  []
  [axial_load]
    type = FunctionDirichletBC
    variable = disp_x
    boundary = right
    function = pull
  []
[]

[Functions]
  [pull]
    type = ParsedFunction
    value = '5*t'
  []
[]

[Materials]
  [strain]
    type = ComputeFiniteStrain
  []

  [stress]
    type = NEMLStress
    model = test_powerdamage
    database = 'damage.xml'
  []
[]

[Postprocessors]
  [damage_index]
    type = ElementAverageValue
    variable = damage_index
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  solve_type = 'NEWTON'
  l_max_its = 50
  l_tol = 1e-8
  nl_max_its = 20
  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-8

  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu     superlu_dist'
  dt = 0.001
  dtmin = 0.0000000001
  end_time = 0.2

  line_search = 'cp'
[]

[Outputs]
  exodus = true
  csv = true
[]
