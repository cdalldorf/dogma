extends Control

var dragging = false
var mouseover = false
var drag_offset = Vector2()
var func_node : LinkedListNode = null

# Called when the node is added to the scene
func _ready() -> void:
	pass
	
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

func _on_panel_mouse_entered() -> void:
	mouseover = true

func _on_panel_mouse_exited() -> void:
	mouseover = false
