extends RigidBody2D

@export var protein_scene: PackedScene
@export var tuning_panel : PackedScene
var function_tree : ScriptingLinks
var UI : Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# initiate function_tree
	function_tree = ScriptingLinks.new()

func timer_tick() -> void:
	# go through list of functions
	function_tree.run_next()
	
	# restart the timer
	$ProcessTimer.start() 

func spawn_protein() -> void:
		# create new ribosome instance
	var prot = protein_scene.instantiate()
	
	# select a spawn location
	var pos = $CollisionShape2D.position
	prot.position = pos
	get_parent().update_ATP(-1)
	
	get_parent().add_child(prot)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (event.is_pressed()):
		self.open_ui()

func open_ui() -> void:
	if UI == null:
		UI = tuning_panel.instantiate()
		function_tree.tree_reset.connect(UI.get_node('HBoxContainer').get_node('Whiteboard')._on_function_tree_reset)
		UI.source_node = self
		add_child(UI)
	else:
		UI.show()
