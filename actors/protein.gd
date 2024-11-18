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


func _process(delta):
	# a target metabolite exists, let's pull it in
	if target_metabolite and is_instance_valid(target_metabolite) and can_consume:
		var direction = (target_metabolite.global_position - global_position).normalized()  # Direction toward the protein
		var force = -direction * gravity_strength * delta  # Apply force with time-based scaling (gravity-like)
		
		# Move metabolite towards the protein
		target_metabolite.position += force  # Apply pull as position change (simulating gravity)
		
		# check if I can eat it
		if global_position.distance_to(target_metabolite.global_position) < 20:  # Collision tolerance
			eat_metabolite(target_metabolite)
	elif can_consume: # check other metabolites in range to see if they can be eaten
		var closest_dist = 9999
		var closest_metab = null
		for metab in potential_eats:
			if is_instance_valid(metab) and not metab.selected:
				var change_posit = (global_position - metab.global_position)
				var distance = (change_posit.x*change_posit.x + change_posit.y*change_posit.y)
				if distance < closest_dist:
					closest_dist = distance
					closest_metab = metab
		if closest_metab:
			closest_metab.selected = true
			target_metabolite = closest_metab
		
# Detect when metabolite is nearby
func _body_entered_range(body):
	if body.is_in_group("metabolites") and body.type == type and body in get_parent().metabolites:
		potential_eats.append(body)


func eat_metabolite(body) -> void:
	body.queue_free()
	get_parent().update_ATP(1)
	can_consume = false
	target_metabolite = null
	$CooldownTimer.start(cooldown_time)

func _collided(body) -> void:
	if can_consume and body.is_in_group('metabolites') and body.type == type:
		eat_metabolite(body)
		
# Reset the ability to consume after the cooldown
func _on_cooldown_timeout():
	can_consume = true
