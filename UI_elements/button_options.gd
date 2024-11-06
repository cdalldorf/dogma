extends VBoxContainer

var buttons : Array = []
@export var scripting_window: PackedScene
signal new_scripting_window(text : String, func_ref : Callable, inputs : int, outputs : int)

func _init() -> void: 
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_parent().get_parent().get_parent()
	# set up buttons (text, function, number inputs, number outputs), should eventually be an input to here somehow
	if root.source_node:
		var input_tuple = [
			['init', Scripting_Utils.init_chain, 0, 1],
			['pass', Scripting_Utils.pass_on, 1, 1],
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



func _on_button_pressed(text : String, func_ref : Callable, inputs : int, outputs : int) -> void:
	new_scripting_window.emit(text, func_ref, inputs, outputs)
	#emit_signal("new_scripting_window", text, func_ref, inputs, outputs)

func _input(_event: InputEvent) -> void:
	pass