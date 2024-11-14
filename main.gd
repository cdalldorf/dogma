extends Node2D

@export var ribo_scene: PackedScene
@export var metab_scene: PackedScene
@export var cell_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD/RibosomeButton.pressed.connect(_on_hud_ribo_button)
	
	# for now just spawn one cell to play around with
	var cell = cell_scene.instantiate()
	cell.position = get_viewport_rect().size / 2
	add_child(cell)
	

func spawn_metab(location : Vector2, type : int) -> void:
	# create new instance
	var metab = metab_scene.instantiate()
	metab.type = type
	metab.update_appearance()
	
	metab.position = location
	add_child(metab)

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


func _on_game_clock_timeout() -> void:
	
		# Get the global position of the SpawnArea parent node
	var spawn_area = $SpawnArea/CollisionShape2D
	
	# Get the CollisionShape2D's shape as a Rect2 (assuming it's a RectangleShape2D)
	var rect : Rect2 = spawn_area.shape.get_rect()
	
	# Calculate the spawn area's global boundaries
	var rect_position = rect.position
	var rect_size = rect.size
	
	# Generate a random position within the global boundaries
	var x = randf_range(rect_position.x, rect_position.x + rect_size.x) - rect_position.x
	var y = randf_range(rect_position.y, rect_position.y + rect_size.y) - rect_position.y
	var rand_point = Vector2(x, y)
	var x2 = randf_range(rect_position.x, rect_position.x + rect_size.x) - rect_position.x
	var y2 = randf_range(rect_position.y, rect_position.y + rect_size.y) - rect_position.y
	var rand_point2 = Vector2(x2, y2)
	
	# Spawn the item at the random point
	spawn_metab(rand_point, 0)
	spawn_metab(rand_point2, 1)
	
	# restart the timer
	$GameClock.start() 
