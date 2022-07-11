[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmax = 200
    ymax = 200
    nx = 40
    ny = 40
  []
  [sub1]
    type = SubdomainBoundingBoxGenerator
    input = gen
    bottom_left = '0 97.5 0'
    top_right = '25 102.5 0'
    block_id = 1
  []
  [sub2]
    type = SubdomainBoundingBoxGenerator
    input = sub1
    bottom_left = '175 97.5 0'
    top_right = '200 102.5 0'
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
[Problem]
  solve = false
[]

[Variables]
  [u]

  []
[]
[Executioner]
  type = Transient
  dt = 1
  end_time = 1
[]

[Outputs]
  exodus = true
  file_base = mazars/results/mesh_setup
[]
