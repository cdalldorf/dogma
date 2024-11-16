extends Node2D
signal exit_cell_wall(body)
var radius : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InternalBody.body_exited.connect(_on_body_exit)
	radius = 150
	update_size()
	#body_exited.connect(_on_barrier_body_exit)
	


func _on_body_exit(body) -> void:
	if body.is_in_group('lipid'):
		update_size(1)
		body.queue_free()
	pass

func update_size(change : float = 0) -> void:
	var delta = change * 10 # scale down, increasing circumference by this much)

	var curr_circum = 2*PI*radius
	var new_circum = curr_circum + delta
	var new_radius = new_circum / (2*PI)
	var scale_increase = (new_radius / radius) - 1
	radius = new_radius
	
	# update sprite utilizing scale
	$Sprite2D.scale.x += scale_increase
	$Sprite2D.scale.y += scale_increase
	
	# update CollisionShape2D by changing its radius
	$InternalBody/CollisionShape2D.shape.radius = radius * .95
	
	# update CollisionPolygon2D by redrawing
	var new_points = []
	var center = $Sprite2D.position
	for i in range(0, 360, 10):
		var angle = i * (PI/180)
		new_points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	call_deferred("set_polygon_deferred", new_points)
	
func set_polygon_deferred(new_points) -> void:
	$CollisionPolygon2D.polygon = new_points
