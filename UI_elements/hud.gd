extends CanvasLayer

signal enemy_button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_enemy_button_pressed() -> void:
	enemy_button.emit()
