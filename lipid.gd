extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group('lipid')
	$DeathTimer.start()

func _on_death_timer_timeout() -> void:
	queue_free()
