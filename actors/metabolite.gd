extends RigidBody2D

var type : int = 0 # type of metabolite, set up for when multiple exist later
var selected = false # flag to see if a protein has selected to consume it

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group('metabolites')
	$DeathTimer.start()

func _on_death_timer_timeout() -> void:
	if selected:
		$DeathTimer.start()
	else:
		queue_free()

func update_appearance() -> void:
	if type == 1:
		$AnimatedSprite2D.animation = '1'
	else:
		$AnimatedSprite2D.animation = 'default'
