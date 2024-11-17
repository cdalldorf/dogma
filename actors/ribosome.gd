extends RigidBody2D

@export var protein_scene: PackedScene
@export var tuning_panel : PackedScene
@export var lipid_scene : PackedScene

var function_tree : ScriptingLinks = null
var UI : Control = null
var lifespan = 120
var locked : bool = false # if so, cannot be modified, disconnect from UI elements

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# initiate function_tree
	if not function_tree:
		function_tree = ScriptingLinks.new()
	$DeathTimer.timeout.connect(_on_death_timer_timeout)
	$DeathTimer.start(lifespan)
	$DeathTimer.start()
	
func timer_tick() -> void:
	# go through list of functions if they've been created yet
	if function_tree.head:
		function_tree.run_next()
	
	# restart the timer
	$ProcessTimer.start() 


############################################################################
### Spawn Functions
############################################################################

func spawn_ribosome() -> void:
	# create new ribosome instance
	var ribo_scene: PackedScene = load("res://actors/ribosome.tscn")
	var ribo = ribo_scene.instantiate()
	ribo.function_tree = function_tree.duplicate(ribo)
	ribo.locked = true
	
	# select a spawn location
	var pos = self.position
	ribo.position = pos
	get_parent().update_ATP(-50)
	
	# give velocity and a direction to spread out a little bit
	var angle = randf_range(0, 2*PI)
	var speed = randf_range(10, 20)
	ribo.linear_velocity = Vector2(cos(angle), sin(angle)) * speed
	
	get_parent().add_child(ribo)

func spawn_protein(prot_type : int = 0) -> void:
		# create new ribosome instance
	var prot = protein_scene.instantiate()
	prot.setup(prot_type)
	
	# select a spawn location
	var pos = self.position
	prot.position = pos
	get_parent().update_ATP(-1)
	
	# give velocity and a direction to spread out a little bit
	var angle = randf_range(0, 2*PI)
	var speed = randf_range(10, 30)
	prot.linear_velocity = Vector2(cos(angle), sin(angle)) * speed
	
	get_parent().add_child(prot)

func spawn_lipid() -> void:
	var lipid = lipid_scene.instantiate()
	
	# select a spawn location
	var pos = self.position
	lipid.position = pos
	get_parent().update_ATP(-1)
	
	# give velocity and a direction to hit cell wall
	var angle = randf_range(0, 2*PI)
	var speed = randf_range(20, 50)
	lipid.linear_velocity = Vector2(cos(angle), sin(angle)) * speed
	
	get_parent().add_child(lipid)



func _on_death_timer_timeout():
	queue_free()
	
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event.is_pressed()):
		self.open_ui()

func open_ui() -> void:
	if locked:
		pass
	elif UI == null:
		UI = tuning_panel.instantiate()
		function_tree.tree_reset.connect(UI.get_node('HBoxContainer').get_node('Whiteboard')._on_function_tree_reset)
		UI.source_node = self
		add_child(UI)
	else:
		UI.show()
