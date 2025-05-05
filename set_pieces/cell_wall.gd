extends Node2D
signal exit_cell_wall(body)
signal enter_cell_wall(body)
signal cell_clicked(_viewport : Node, _event : InputEvent, _shape_idx : int)
var radius : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$InternalBody.body_exited.connect(_on_body_exit)
	$InternalBody.body_entered.connect(_on_body_enter)
	$InternalBody.input_event.connect(_cell_clicked)
	radius = 150
	update_size()

func _cell_clicked(viewport : Node, event : InputEvent, shape_idx : int) -> void:
	cell_clicked.emit(viewport, event, shape_idx)

func _on_body_exit(body) -> void:
	if body.is_in_group('lipids'):
		update_size(1)
		body.queue_free()
	else:
		exit_cell_wall.emit(body)

func _on_body_enter(body) -> void:
	enter_cell_wall.emit(body)

func update_size(change : float = 0) -> void:
	var delta = change * 4 # scale down, increasing circumference by this much)

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
