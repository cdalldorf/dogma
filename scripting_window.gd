extends Control
@export var wait_texture: Texture2D  # A texture for input sockets
@export var ready_texture: Texture2D  # A texture for output sockets

var drawing = false # is a wire being drawn currently, pause dragging
var dragging = false
var mouseover = false
var drag_offset = Vector2()
var func_node : LinkedListNode = null
var num_inputs : int = 0
var num_outputs : int = 0
var input_sockets = []
var output_sockets = []

# Called when the node is added to the scene
func _ready() -> void:
	call_deferred("create_sockets")
	if func_node != null:
		func_node.output_true.connect(_on_function_completed)

# gets called when the function is run for this node
func _on_function_completed() -> void:
	for socket in output_sockets:
		socket.texture_normal = ready_texture

func create_sockets() -> void:
	create_input_sockets(num_inputs)
	create_output_sockets(num_outputs)

func set_text(text : String) -> void:
	$Panel/RichTextLabel.text = text

func create_input_sockets(count : int) -> void:
	var panel_width = $Panel.size.x
	var spacing = panel_width / (count + 1)
	
	for i in range(count):
		var socket = TextureButton.new()
		socket.texture_normal = wait_texture
		socket.scale.x = 0.3
		socket.scale.y = 0.3
		socket.name = "Input " + str(i + 1)
		socket.position = Vector2(spacing*(i+1) - (socket.size.x / 2), 0)  # Adjust positioning based on layout needs
		socket.mouse_filter = Control.MOUSE_FILTER_PASS
		socket.set('input_output', 'input')
		socket.set('wire', null)
		socket.pressed.connect(_on_socket_pressed.bind(socket)) #  butt.pressed.connect(_on_button_pressed.bind(tuple[0], tuple[1], tuple[2], tuple[3]))
		add_child(socket)
		input_sockets.append(socket)

func create_output_sockets(count : int) -> void:
	var panel_width = $Panel.size.x
	var spacing = panel_width / (count + 1)
	
	for i in range(count):
		var socket = TextureButton.new()
		socket.texture_normal = wait_texture
		socket.scale.x = 0.3
		socket.scale.y = 0.3
		socket.name = "Output " + str(i + 1)
		socket.position = Vector2(spacing*(i+1) - (socket.size.x / 2), $Panel.size.y)  # Adjust positioning based on layout needs
		socket.mouse_filter = Control.MOUSE_FILTER_PASS
		socket.set('input_output', 'output')
		socket.set('wire', null)
		socket.pressed.connect(_on_socket_pressed.bind(socket)) #  butt.pressed.connect(_on_button_pressed.bind(tuple[0], tuple[1], tuple[2], tuple[3]))
		add_child(socket)
		output_sockets.append(socket)

# handle socket selection
func _on_socket_pressed(socket : TextureButton) -> void:
	# we need to check if this is first selection or second to decide if to start or finish a wire
	if get_parent().wire_drag != null and socket.get('input_output') == get_parent().wire_drag.get('input_output'):
		# this is the second selection and they are not different types
		if get_parent().wire_drag.get('input_output') == 'input':
			draw_wires(get_parent().wire_drag, socket)
		else:
			draw_wires(socket, get_parent().wire_drag)
		get_parent().wire_drag = null
	else:
		# no wires have been started, let's start one
		get_parent().wire_drag = socket
	
# Function to draw a line between two sockets
func draw_wires(socket_a: TextureButton, socket_b: TextureButton):
	# Create a Line2D node
	var line = Line2D.new()

	# Set the points of the line to the positions of the sockets
	line.add_point(socket_a.global_position)  # Use global_position for correct placement
	socket_a.set('wire', line)
	line.add_point(socket_b.global_position)
	socket_b.set('wire', line)
	# set the line color and width
	line.default_color = Color(0, 0, 0) 
	line.width = 2  # Line width

	# Add the line to the parent node or appropriate node in the scene
	get_parent().add_child(line)
	
	
	# ZZZ TODO - need to also functionally connect wires (make the LinkedListNodes related)



# Handle button press event
func _on_button_pressed() -> void:
	dragging = true

# Handle button release event
func _on_button_released() -> void:
	dragging = false

# This function will be called every time input is received
func _input(event: InputEvent) -> void:
	# Check for mouse button events
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and mouseover:
				dragging = true
			elif not event.pressed:
				dragging = false

	# Handle mouse motion while dragging
	if dragging and event is InputEventMouseMotion:
		# Update the position based on mouse movement
		position += event.relative
		
		# check for lines
		for socket in input_sockets:
			if socket.get('wire') != null:
				socket.get('wire').set_point_position(0, socket.wire.get_point_position(0) + event.relative)
				print('hi')
		for socket in output_sockets:
			if socket.get('wire') != null:
				socket.get('wire').set_point_position(1, socket.wire.get_point_position(1) + event.relative)

func _on_panel_mouse_entered() -> void:
	mouseover = true

func _on_panel_mouse_exited() -> void:
	mouseover = false
