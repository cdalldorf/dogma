extends RigidBody2D

var metab_type : int = 0 # type of metabolite, set up for when multiple exist later

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$DeathTimer.start()

func _on_death_timer_timeout() -> void:
	queue_free()
