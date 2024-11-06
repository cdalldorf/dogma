extends CanvasLayer

signal ribo_button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_ribosome_button_pressed() -> void:
	ribo_button.emit()
