extends VBoxContainer

var buttons : Array = []
@export var scripting_window: PackedScene
signal new_scripting_window(text : String, func_ref : Callable, inputs : int, outputs : int, options : Array)

func _init() -> void: 
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# finding the tuning panel... I think
	var root = get_parent().get_parent().get_parent()
	# set up buttons (text, function, number inputs, number outputs, options = []), should eventually be an input to here somehow
	if root.source_node:
		var input_tuple = [
			['pass', Scripting_Utils.pass_on, 1, 1, []],
			['random_switch', Scripting_Utils.random_switch, 1, 2, []],
			['spawn_prot', root.source_node.spawn_protein, 1, 0, [0, 1]]
		]
		for tuple in input_tuple:
			var butt = Button.new()
			butt.text = tuple[0]
			butt.mouse_filter = Control.MOUSE_FILTER_PASS
			butt.set('func_ref', tuple[1])
			butt.pressed.connect(_on_button_pressed.bind(tuple[0], tuple[1], tuple[2], tuple[3], tuple[4]))
			self.add_child(butt)



func _on_button_pressed(text : String, func_ref : Callable, inputs : int, outputs : int, options : Array = []) -> void:
	new_scripting_window.emit(text, func_ref, inputs, outputs, options) # passes to whiteboard

func _input(_event: InputEvent) -> void:
	pass
