
[Problem]
  kernel_coverage_check = false
[]

[Variables]
   [u]
     [InitialCondition]
      type = ConstantIC
      value = 0.1
     []
    #  order = second
 []
[]
[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 10
    ny = 10
    # nz = 10
    # subdomain_ids = 2
    # elem_type = quad8
  []
[]


# [AuxVariables]
# [average]
# []
# []

# [AuxKernels]
#  [averger]
#  type=ElementUOAux
#  element_user_object = ele_avg
#  variable = average
#  []
# []


[Materials]
 [constant]
    type = GenericConstantMaterial 
    prop_names = 'constant'
    prop_values = '2.0'
  []
[]
[UserObjects]
  [ele_avg]
    type = RadialAverage
    material_name = constant
    execute_on = "timestep_end"
    # block = 2
    r_cut = 0.1
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
  end_time = 5
  dt = 1.0
[]
[Outputs]
  # exodus = true
  [Exodus]
  file_base = "self/test_avg/test"
  type = Exodus
  output_material_properties = true
  []
[]
