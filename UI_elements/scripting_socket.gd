extends TextureButton

class_name ScriptingSocket

var input : bool = false # if not an input, it is an output
var wire : Line2D = null
var downstream = []

# Constructor method
func _init(input_check : bool, input_str : String):
	input = input_check
	scale.x = 0.3
	scale.y = 0.3
	name = input_str
