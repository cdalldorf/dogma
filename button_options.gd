extends VBoxContainer

var buttons : Array = []
@export var scripting_window: PackedScene

func _init() -> void: 
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_parent().get_parent().get_parent()
	# set up buttons (text, function, number inputs, number outputs), should eventually be an input to here somehow
	if root.source_node:
		var input_tuple = [
			['init', Scripting_Utils.init_chain, 0, 1],
			['spawn_prot', root.source_node.spawn_protein, 1, 0]
		]
		for tuple in input_tuple:
			var butt = Button.new()
			butt.text = tuple[0]
			butt.mouse_filter = Control.MOUSE_FILTER_PASS
			butt.set('func_ref', tuple[1])
			butt.pressed.connect(_on_button_pressed.bind(tuple[0], tuple[1], tuple[2], tuple[3]))
			#_on_button_pressed)
			self.add_child(butt)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed(text : String, func_ref : Callable, inputs : int, outputs : int) -> void:
	var click_position = get_global_mouse_position()
	var new_wind = scripting_window.instantiate()
	new_wind.func_node = LinkedListNode.new(func_ref)
	new_wind.set_text(text)
	new_wind.num_inputs = inputs
	new_wind.num_outputs = outputs

	# position the new window
	new_wind.position = click_position - new_wind.get_child(0).size / 2

	# add to the main controller
	get_parent().get_parent().get_parent().add_child(new_wind)
	get_parent().get_parent().get_parent().scripting_windows.append(new_wind)
	
func _input(event: InputEvent) -> void:
	pass
