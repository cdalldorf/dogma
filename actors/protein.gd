extends RigidBody2D

var gravity_strength = 50
var target_metabolite = null
var can_consume = true
var cooldown_time = 2
var lifespan = 60
var type = 0
var potential_eats = []

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


# Detect when metabolite is nearby
func _body_entered_range(body):
	# first check if it should be eaten
	if body.is_in_group("metabolites") and not body.selected and body.type == type and body in get_parent().metabolites:
		potential_eats.append(body)
		
		# next check if hungry, eat if so
		if can_consume:
			can_consume = false
			eat_metabolite(body)


func eat_metabolite(body) -> void:
	# pull the metabolite to the protein
	body.selected = true
	var direction = (body.global_position - global_position).normalized()  # Direction toward the protein
	var force = -direction * gravity_strength  # Apply force with time-based scaling (gravity-like)
	body.position += force  # Apply pull as position change (simulating gravity)
	
	# eat the metabolite
	body.queue_free()
	get_parent().update_ATP(1)
	$CooldownTimer.start(cooldown_time)

# Reset the ability to consume after the cooldown
func _on_cooldown_timeout():
	can_consume = true
	
	# let's look for something to eat
	for body in potential_eats:
		if is_instance_valid(body):  # Collision tolerance
			eat_metabolite(body)
			break
