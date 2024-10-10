extends Node2D

@export var ribo_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_hud_ribo_button() -> void:
	spawn_ribosome()
	
	
func spawn_ribosome() -> void:
	# create new ribosome instance
	var ribo = ribo_scene.instantiate()
	
	# select a spawn location
	var pos = get_viewport_rect().size / 2
	ribo.position = pos
	
	add_child(ribo)

# This function is triggered when an object exits the cell wall
func _on_exit_cell_wall(body: Node2D) -> void:
	if body.is_in_group('ribosomes'):
		body.queue_free()
	if body.is_in_group('proteins'):
		body.queue_free()
