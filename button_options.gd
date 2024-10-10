extends VBoxContainer

var buttons : Array = []
@export var scripting_window: PackedScene

func _init() -> void: 
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_parent().get_parent().get_parent()
	var input_tuple = [
		['init', Scripting_Utils.init_chain],
		['spawn_prot', root.source_node.spawn_protein]
	]
	for tuple in input_tuple:
		print('hi')
		var butt = Button.new()
		butt.text = tuple[0]
		butt.set('func_ref', tuple[1])
		butt.pressed.connect(_on_button_pressed.bind(tuple[1]))
		#_on_button_pressed)
		self.add_child(butt)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed(func_ref : Callable) -> void:
	var click_position = get_global_mouse_position()
	var new_wind = scripting_window.instantiate()
	new_wind.func_node = LinkedListNode.new(func_ref)

	# position the new window
	new_wind.position = click_position - new_wind.get_child(0).size / 2

	# check if the new_wind has been added to the scene tree
	get_parent().get_parent().get_parent().add_child(new_wind)

func _input(event: InputEvent) -> void:
	pass
