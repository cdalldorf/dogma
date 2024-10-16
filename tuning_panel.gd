extends Control

var source_node : Node = null
var mouseover = false
var dragging = false
var wire_drag = null
var scripting_windows = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# This function will be called every time input is received
func _input(event: InputEvent) -> void:
	# Check for mouse button events
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not mouseover:
				self.hide()
			elif event.pressed and mouseover:
				dragging = true
			elif not event.pressed:
				dragging = false
				
	if dragging and event is InputEventMouseMotion:
		# check if a child is being dragged or wire being drawn
		var other_moving = false
		for wind in scripting_windows:
			if wind.dragging or wind.drawing:
				other_moving = true
				break
		# Update the position based on mouse movement
		if not other_moving: position += event.relative
		
func _on_mouse_entered() -> void:
	mouseover = true

func _on_mouse_exited() -> void:
	mouseover = false


# Handle button press event
func _on_button_pressed() -> void:
	dragging = true

# Handle button release event
func _on_button_released() -> void:
	dragging = false
