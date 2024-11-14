extends Node2D

var ATP_ct = 200 # starting ATP value

@export var ribo_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CellWall/Area2D.body_exited.connect(_on_exit_cell_wall)
	spawn_ribosome()

func update_ATP(amount: int):
	ATP_ct += amount
	$CellWall/ATP_count_label.text = str(ATP_ct)

func spawn_ribosome() -> void:
	# create new ribosome instance
	var ribo = ribo_scene.instantiate()
	
	# select a spawn location
	var pos = global_position# + $CellWall/Area2D/CollisionShape2D.shape.radius / 2 # get_viewport_rect().size / 2
	ribo.position = Vector2.ZERO
	
	add_child(ribo)

# This function is triggered when an object exits the cell wall
func _on_exit_cell_wall(body: Node2D) -> void:
	if body.is_in_group('ribosomes'):
		body.queue_free()
	if body.is_in_group('proteins'):
		body.queue_free()
