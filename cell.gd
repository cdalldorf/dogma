extends Node2D

var ATP_ct = 200 # starting ATP value
var division_check = 1000 # if ATP gets above 1000, divide
var metabolites = []
@export var ribo_scene: PackedScene
@export var cell_wall_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cell_wall = cell_wall_scene.instantiate()
	cell_wall.exit_cell_wall.connect(_on_exit_cell_wall)
	cell_wall.enter_cell_wall.connect(_on_enter_cell_wall)
	add_child(cell_wall)
	spawn_ribosome()
	
func update_ATP(amount: int):
	ATP_ct += amount
	$CellWall/ATP_count_label.text = str(ATP_ct)
	if amount > division_check:
		cell_divide()

func cell_divide():
	print('you win! or as close to winning as you can get until I implement cell division')

func spawn_ribosome() -> void:
	# create new ribosome instance
	var ribo = ribo_scene.instantiate()
	
	# select a spawn location
	#var pos = global_position# + $CellWall/Area2D/CollisionShape2D.shape.radius / 2 # get_viewport_rect().size / 2
	ribo.position = Vector2.ZERO
	
	add_child(ribo)

# This function is triggered when an object exits the cell wall
func _on_exit_cell_wall(body: Node2D) -> void:
	if body.is_in_group('ribosomes'):
		body.queue_free()
	if body.is_in_group('proteins'):
		body.queue_free()

func _on_enter_cell_wall(body: Node2D) -> void:
	if body.is_in_group('metabolites'):
		metabolites.append(body)
