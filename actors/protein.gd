extends RigidBody2D

var gravity_strength = 50
var target_metabolite = null
var can_consume = true
var cooldown_time = 5
var lifespan = 20
var type = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Consume_Range.body_entered.connect(_body_entered_range)
	$CooldownTimer.timeout.connect(_on_cooldown_timeout)
	$DeathTimer.timeout.connect(_on_death_timer_timeout)
	$DeathTimer.start(lifespan)
	$DeathTimer.start()

func setup(prot_type):
	type = prot_type
	# add changing appearance here based on type, other setup functions

func _on_death_timer_timeout() -> void:
	queue_free()


func _process(delta):
	if target_metabolite and is_instance_valid(target_metabolite):
		var direction = (target_metabolite.global_position - global_position).normalized()  # Direction toward the protein
		var force = -direction * gravity_strength * delta  # Apply force with time-based scaling (gravity-like)
		
		# Move metabolite towards the protein (or apply force if it's a RigidBody2D)
		target_metabolite.position += force  # Apply pull as position change (simulating gravity)
		
		# check if I can eat it
		if global_position.distance_to(target_metabolite.global_position) < 20:  # Collision tolerance
			eat_metabolite(target_metabolite)

# Detect when metabolite is nearby
func _body_entered_range(body):
	if body.is_in_group("metabolite") and body.type == type:
		if not body.selected:
			target_metabolite = body
			body.selected = true


func eat_metabolite(body) -> void:
	body.queue_free()
	get_parent().update_ATP(1)
	can_consume = false
	$CooldownTimer.start(cooldown_time)

func _collided(body) -> void:
	if can_consume and body.is_in_group('metabolite') and body.type == type:
		eat_metabolite(body)
		
# Reset the ability to consume after the cooldown
func _on_cooldown_timeout():
	can_consume = true
