extends Control

var source_node : Node = null
var mouseover = false
var dragging = false
var wire_drag = null
var submenu_just_closed = false
@onready var file_dialog_save = $Save_FileDialog
@onready var file_dialog_load = $Load_FileDialog
signal closed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/Whiteboard.wires_connect.connect(_wires_connect)
	# connect load and save buttons
	$HBoxContainer/VBoxContainer/HBoxContainer/Load_Button.pressed.connect(_load_config)
	$HBoxContainer/VBoxContainer/HBoxContainer/Save_Button.pressed.connect(_save_config)
	$Save_FileDialog.file_selected.connect(_save_file)
	$Load_FileDialog.file_selected.connect(_load_file)

func _load_config():
	file_dialog_load.current_path = 'res://player_created_data/saved_configurations/'
	file_dialog_load.size = Vector2(400, 300)
	file_dialog_load.filters = ['*.dogma_config']
	file_dialog_load.popup_centered()

func _load_file(path : String):
	# load in file, overwrite current function tree with it
	var file = FileAccess.open(path, FileAccess.READ)
	var file_contents = file.get_as_text()
	file.close()
	var new_func_tree = ScriptingLinks.unserialize(file_contents, get_parent().start_ribo)
	get_parent().function_tree = new_func_tree
	# TO DO - make this appear in the UI also
	
func _save_config():
	file_dialog_save.current_path = 'res://player_created_data/saved_configurations/'
	file_dialog_save.size = Vector2(400, 300)
	file_dialog_save.filters = ['*.dogma_config']
	file_dialog_save.popup_centered()

func _save_file(path : String):
	# convert the function_tree to a recreatable format
	var saved_data = get_parent().function_tree.serialize()
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(saved_data)
		file.close()

# This function will be called every time input is received
func _input(event: InputEvent) -> void:
	# check if submenu is open, priority held
	if submenu_just_closed:
		dragging = false
		submenu_just_closed = false
		return
	
	# Check for mouse button events
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not mouseover:
				close_tuning_panel()
			elif event.pressed and mouseover:
				dragging = true
			elif not event.pressed:
				dragging = false
				
	if dragging and event is InputEventMouseMotion:
		# check if a child is being dragged or wire being drawn
		var other_moving = false
		for wind in get_node('HBoxContainer').get_node('Whiteboard').scripting_windows:
			if wind.dragging or wind.drawing:
				other_moving = true
				break
		# Update the position based on mouse movement
		if not other_moving: position += event.relative
		
func _on_mouse_entered() -> void:
	mouseover = true

func _on_mouse_exited() -> void:
	mouseover = false

func close_tuning_panel() -> void:
	# let's close the tuning panel
	get_parent().locked = true
	closed.emit()
	self.queue_free()
	self.hide()

# Handle button press event
func _on_button_pressed() -> void:
	dragging = true

# Handle button release event
func _on_button_released() -> void:
	dragging = false


# functions for handling ScriptingWindow and ScriptingLinks connections
func _wires_connect(input : Node, output : Node, socket_index : int):
	output.func_node.add_child(input.func_node, socket_index)
