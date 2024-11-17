extends Node
class_name Scripting_Utils

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


static func pass_on() -> Array:
	return [true]
	
static func init_chain() -> Array:
	return [true]
	
static func random_switch(chance : float = .5) -> Array: # eventually make this adjustable
	var check = randf()
	if check < chance:
		return [true, false]
	else:
		return [false, true]
