extends RigidBody2D

var gravity_strength = 500
var target_metabolite = null
var can_consume = true
var cooldown_time = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Consume_Range.body_entered.connect(_body_entered_range)
	body_entered.connect(_collided)
	$CooldownTimer.timeout.connect(_on_cooldown_timeout)

func _process(delta):
	if target_metabolite and is_instance_valid(target_metabolite):
		var direction = (target_metabolite.global_position - global_position).normalized()  # Direction toward the protein
		var force = -direction * gravity_strength * delta  # Apply force with time-based scaling (gravity-like)
		
		# Move metabolite towards the protein (or apply force if it's a RigidBody2D)
		target_metabolite.position += force  # Apply pull as position change (simulating gravity)


# Detect when metabolite is nearby
func _body_entered_range(body):
	if body.is_in_group("metabolite"):
		if not body.selected:
			target_metabolite = body
			body.selected = true


func eat_metabolite(body) -> void:
	body.queue_free()
	print('yummy! need to add eating and add ATP somewhere, printed from protein.gd')
	can_consume = false
	$CooldownTimer.start(cooldown_time)

func _collided(body) -> void:
	print('hi!')
	if body.is_in_group('metabolite') and can_consume:
		eat_metabolite(body)
		
# Reset the ability to consume after the cooldown
func _on_cooldown_timeout():
	can_consume = true
