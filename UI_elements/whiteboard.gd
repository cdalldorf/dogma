extends Panel
@export var scripting_window: PackedScene

var scripting_windows = []
var wire_drag : ScriptingSocket = null 
signal wires_connect(input : Node, output : Node)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var butt_opts = get_parent().get_node('ScrollContainer').get_child(0)
	butt_opts.new_scripting_window.connect(_new_scripting_window)
	
	# create the init_node, set to head of function tree
	var new_wind = scripting_window.instantiate()
	var init_ref = get_parent().get_parent().source_node.function_tree.head
	new_wind.setup(init_ref, 'init', 0, 1, [])
	
	# position the new window
	new_wind.position = position# - new_wind.get_child(0).size / 2
	
	# connect its signals
	new_wind.socket_pressed.connect(_socket_pressed)
	
	# add to the main controller
	add_child(new_wind)
	scripting_windows.append(new_wind)

func _on_function_tree_reset():
	for wind in scripting_windows:
		wind._on_function_tree_reset()


func _new_scripting_window(text: String, func_ref: Callable, inputs: int, outputs: int, options : Array) -> void:
	#var click_position = get_global_mouse_position()
	var new_wind = scripting_window.instantiate()
	new_wind.setup(func_ref, text, inputs, outputs, options)

	# position the new window
	new_wind.position = position# - new_wind.get_child(0).size / 2
	
	# connect its signals
	new_wind.socket_pressed.connect(_socket_pressed)
	
	# add to the main controller
	add_child(new_wind)
	scripting_windows.append(new_wind)

func _socket_pressed(socket: ScriptingSocket):
	# we need to check if this is first selection or second to decide if to start or finish a wire
	if wire_drag != null and socket.input != wire_drag.input:
		# this is the second selection and they are not different types
		if wire_drag.input:
			draw_wires(wire_drag, socket)
		else:
			draw_wires(socket, wire_drag)
		wire_drag = null
	else:
		# no wires have been started, let's start one
		wire_drag = socket

# Function to draw a line between two sockets
func draw_wires(socket_a: ScriptingSocket, socket_b: ScriptingSocket):
	# Create a Line2D node
	var line = Line2D.new()
	
	# Get the texture's original size and adjust for scale
	var texture_size_a = socket_a.texture_normal.get_size() * socket_a.scale.x
	var texture_size_b = socket_b.texture_normal.get_size() * socket_b.scale.x

	# Calculate start and end positions based on center-bottom of each TextureButton
	var start_pos = socket_a.get_global_rect().position + Vector2(texture_size_a.x / 2, 0)
	var end_pos = socket_b.get_global_rect().position + Vector2(texture_size_b.x / 2, texture_size_b.y)
	start_pos -= get_global_position()
	end_pos -= get_global_position()
	
	# Set the points of the line to the positions of the sockets
	line.add_point(start_pos)  # Use global_position for correct placement
	line.add_point(end_pos)
	socket_a.wire = line
	socket_b.wire = line
	
	# set the line color and width
	line.default_color = Color(0, 0, 0) 
	line.width = 2  # Line width
	
	# Add the line to the parent node or appropriate node in the scene
	add_child(line)
	
	# need to also functionally connect wires (make the LinkedListNodes related)
	socket_b.downstream.append(socket_a)
	wires_connect.emit(socket_a.get_parent(), socket_b.get_parent())
