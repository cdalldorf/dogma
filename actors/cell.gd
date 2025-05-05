extends Node2D

var function_tree : ScriptingLinks = null # function tree for ribosomes
var start_ribo = null
var ATP_ct = 200 # starting ATP value
var division_check = 1000 # if ATP gets above 1000, divide
var metabolites = []
var ribo_children : Array = []
var enemy : bool = false # checks if this is an enemy cell, if so make it uneditable
var UI : Control = null
var locked : bool = false # if so, cannot be modified, disconnect from UI elements
@export var ribo_scene: PackedScene
@export var cell_wall_scene: PackedScene
@export var tuning_panel : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cell_wall = cell_wall_scene.instantiate()
	cell_wall.exit_cell_wall.connect(_on_exit_cell_wall)
	cell_wall.enter_cell_wall.connect(_on_enter_cell_wall)
	cell_wall.cell_clicked.connect(_cell_clicked)
	add_child(cell_wall)
	
	# initiate function_tree for ribosomes to inherit when spawned
	if not function_tree:
		function_tree = ScriptingLinks.new()
		start_ribo = spawn_ribosome()

func load_function_tree(option : String = 'default') -> void:
	var file_path = "res://enemy_configurations/"+option+".dogma_config"
	# load in file, overwrite current function tree with it
	var file = FileAccess.open(file_path, FileAccess.READ)
	var file_contents = file.get_as_text()
	file.close()
	var new_func_tree = ScriptingLinks.unserialize(file_contents, start_ribo)
	start_ribo.function_tree = new_func_tree
	# TO DO - make this appear in the UI also

func _cell_clicked(viewport : Node, event : InputEvent, shape_idx : int) -> void:
	if event.is_pressed():
		self.open_ui()

func open_ui() -> void:
	if locked or enemy: # don't open if locked or enemy
		pass
	elif UI == null:
		UI = tuning_panel.instantiate()
		UI.source_node = start_ribo
		UI.closed.connect(UI_closed)
		add_child(UI)
		UI.show()
	else:
		UI.show()

func UI_closed() -> void:
	# update the ribosome with the new function tree
	start_ribo.function_tree = function_tree

func update_ATP(amount: int):
	ATP_ct += amount
	$CellWall/ATP_count_label.text = str(ATP_ct)
	if amount > division_check:
		cell_divide()

func cell_divide():
	print('you win! or as close to winning as you can get until I implement cell division')

func spawn_ribosome():
	# create new ribosome instance
	var ribo = ribo_scene.instantiate()
	
	# select a spawn location
	#var pos = global_position# + $CellWall/Area2D/CollisionShape2D.shape.radius / 2 # get_viewport_rect().size / 2
	ribo.position = Vector2.ZERO
	ribo_children.append(ribo)
	
	add_child(ribo)
	return(ribo)

# This function is triggered when an object exits the cell wall
func _on_exit_cell_wall(body: Node2D) -> void:
	if body.is_in_group('ribosomes'):
		body.queue_free()
	if body.is_in_group('proteins'):
		body.queue_free()

func _on_enter_cell_wall(body: Node2D) -> void:
	if body.is_in_group('metabolites'):
		metabolites.append(body)
