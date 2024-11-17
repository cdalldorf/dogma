extends Control
@export var wait_texture: Texture2D  # A texture for input sockets
@export var ready_texture: Texture2D  # A texture for output sockets

var drawing = false # is a wire being drawn currently, pause dragging
var dragging = false
var mouseover = false
var drop_menu_open = false
var drop_menu_just_closed = false
var drag_offset = Vector2()
var func_node : LinkedListNode = null
var num_inputs : int = 0
var num_outputs : int = 0
var input_sockets = []
var output_sockets = []
var options = []
var index_to_option : Dictionary

signal socket_pressed(socket : ScriptingSocket)



# call every time after instantiating object
func setup(func_ref, text : String, inputs : int, outputs : int, inp_options = []) -> void:
	if func_ref is Callable:
		func_node = LinkedListNode.new(func_ref, outputs)
	elif func_ref is LinkedListNode:
		func_node = func_ref
	set_text(text)
	num_inputs = inputs
	num_outputs = outputs
	options = inp_options

# Called when the node is added to the scene
func _ready() -> void:
	call_deferred("create_sockets")
	call_deferred("populate_options")
	if func_node != null:
		func_node.func_output.connect(function_ran)

func function_ran(check : Array) -> void:
	for i in range(output_sockets.size()):
		if check[i]:
			output_sockets[i].texture_normal = ready_texture
			for downstream in output_sockets[i].downstream:
				downstream.texture_normal = ready_texture
			
# gets called when the function is run for this node
func _on_function_completed() -> void:
	for socket in output_sockets:
		socket.texture_normal = ready_texture
		for downstream in socket.downstream:
			downstream.texture_normal = ready_texture

# reset all sockets' textures to waiting
func _on_function_tree_reset() -> void:
	for socket in input_sockets+output_sockets:
		socket.texture_normal = wait_texture



######################################################
#### UI intantiate functions
######################################################
func create_sockets() -> void:
	create_input_sockets(num_inputs)
	create_output_sockets(num_outputs)

func create_input_sockets(count : int) -> void:
	var panel_width = $Panel.size.x
	var spacing = panel_width / (count + 1)
	
	for i in range(count):
		var socket = ScriptingSocket.new(true, "Input " + str(i + 1), i)
		socket.texture_normal = wait_texture
		socket.position = Vector2(spacing*(i+1) - (socket.size.x / 2), 0)  # Adjust positioning based on layout needs
		socket.mouse_filter = Control.MOUSE_FILTER_PASS
		socket.pressed.connect(_on_socket_pressed.bind(socket)) #  butt.pressed.connect(_on_button_pressed.bind(tuple[0], tuple[1], tuple[2], tuple[3]))
		add_child(socket)
		input_sockets.append(socket)

func create_output_sockets(count : int) -> void:
	var panel_width = $Panel.size.x
	var spacing = panel_width / (count + 1)
	
	for i in range(count):
		var socket = ScriptingSocket.new(false, "Input " + str(i + 1), i)
		socket.texture_normal = wait_texture
		socket.position = Vector2(spacing*(i+1) - (socket.size.x / 2), $Panel.size.y)  # Adjust positioning based on layout needs
		socket.mouse_filter = Control.MOUSE_FILTER_PASS
		socket.pressed.connect(_on_socket_pressed.bind(socket)) #  butt.pressed.connect(_on_button_pressed.bind(tuple[0], tuple[1], tuple[2], tuple[3]))
		add_child(socket)
		output_sockets.append(socket)

func populate_options() -> void:
	var i = 0
	for option in options:
		index_to_option[i] = option
		i += 1
		$Panel/OptionButton.add_item(str(option))
	$Panel/OptionButton.item_selected.connect(update_func_opts)
	$Panel/OptionButton.toggled.connect(_option_menu_toggled)
	$Panel/OptionButton.selected = int(len(options) / 2)
	if len(options) > 0:
		func_node.inputs = index_to_option[int(len(options) / 2)]

##################################################
# UI interacted with
##################################################
func _option_menu_toggled(toggled : bool):
	if toggled and not drop_menu_open:
		# menu just opened
		$Panel/OptionButton.mouse_filter = MOUSE_FILTER_STOP
	elif not toggled and drop_menu_open:
		# menu just closed
		get_parent().get_parent().get_parent().submenu_just_closed = true
		$Panel/OptionButton.mouse_filter = MOUSE_FILTER_PASS
		drop_menu_just_closed = true
	drop_menu_open = toggled

func update_func_opts(index):
	if index in index_to_option:
		func_node.inputs = index_to_option[index]
	else:
		func_node.inputs = index

func set_text(text : String) -> void:
	$Panel/RichTextLabel.text = text

# handle socket selection
func _on_socket_pressed(socket : ScriptingSocket) -> void:
	socket_pressed.emit(socket)
	
# Handle button press event
func _on_button_pressed() -> void:
	dragging = true

# Handle button release event
func _on_button_released() -> void:
	dragging = false

# This function will be called every time input is received
func _input(event: InputEvent) -> void:
	# check for drop menu
	if drop_menu_just_closed:
		drop_menu_just_closed = false
		dragging = false
		mouseover = false
		return
		
	# Check for mouse button events
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and mouseover:
				dragging = true
			elif not event.pressed:
				dragging = false

	# Handle mouse motion while dragging
	if dragging and event is InputEventMouseMotion:
		# Get the parent (Whiteboard) rect size and position
		var whiteboard = get_parent()  # Assuming this is the Whiteboard
		var whiteboard_rect = Rect2(whiteboard.position, whiteboard.size)

		# Update the position based on mouse movement
		var new_position = position + event.relative
		new_position.x = clamp(new_position.x, whiteboard_rect.position.x, whiteboard_rect.position.x + whiteboard_rect.size.x - get_child(0).size.x)
		new_position.y = clamp(new_position.y, whiteboard_rect.position.y, whiteboard_rect.position.y + whiteboard_rect.size.y - get_child(0).size.y)
		position = new_position#event.relative
		
		# check for lines
		for socket in input_sockets:
			if socket.wire != null:
				socket.wire.set_point_position(0, socket.wire.get_point_position(0) + event.relative)
		for socket in output_sockets:
			if socket.wire != null:
				socket.wire.set_point_position(1, socket.wire.get_point_position(1) + event.relative)

func _on_panel_mouse_entered() -> void:
	mouseover = true

func _on_panel_mouse_exited() -> void:
	mouseover = false
