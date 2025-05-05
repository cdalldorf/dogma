extends RigidBody2D

@export var protein_scene: PackedScene
@export var lipid_scene : PackedScene

var function_tree : ScriptingLinks = null
var lifespan = 120

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# initiate function_tree
	if not function_tree:
		function_tree = ScriptingLinks.new()
	$DeathTimer.timeout.connect(_on_death_timer_timeout)
	$DeathTimer.start(lifespan)
	$DeathTimer.start()
	
func timer_tick() -> void:
	# go through list of functions if they've been created yet
	if function_tree.head:
		function_tree.run_next()
	
	# restart the timer
	$ProcessTimer.start() 

func _on_death_timer_timeout():
	queue_free()

############################################################################
### Spawn Functions
############################################################################

func spawn_ribosome() -> void:
	# if not enough ATP, cannot do
	if get_parent().ATP_ct < 50:
		return
		
	# create new ribosome instance
	var ribo_scene: PackedScene = load("res://actors/ribosome.tscn")
	var ribo = ribo_scene.instantiate()
	ribo.function_tree = function_tree.duplicate(ribo)
	
	# select a spawn location
	var pos = self.position
	ribo.position = pos
	get_parent().update_ATP(-50)
	
	# give velocity and a direction to spread out a little bit
	var angle = randf_range(0, 2*PI)
	var speed = randf_range(10, 20)
	ribo.linear_velocity = Vector2(cos(angle), sin(angle)) * speed
	
	get_parent().add_child(ribo)

func spawn_protein(prot_type : int = 0) -> void:
	# if not enough ATP, cannot do
	if get_parent().ATP_ct < 1:
		return
		
	# create new ribosome instance
	var prot = protein_scene.instantiate()
	prot.setup(prot_type)
	
	# select a spawn location
	var pos = self.position
	prot.position = pos
	get_parent().update_ATP(-1)
	
	# give velocity and a direction to spread out a little bit
	var angle = randf_range(0, 2*PI)
	var speed = randf_range(10, 30)
	prot.linear_velocity = Vector2(cos(angle), sin(angle)) * speed
	
	get_parent().add_child(prot)

func spawn_lipid() -> void:
	# if not enough ATP, cannot do
	if get_parent().ATP_ct < 1:
		return
		
	var lipid = lipid_scene.instantiate()
	
	# select a spawn location
	var pos = self.position
	lipid.position = pos
	get_parent().update_ATP(-1)
	
	# give velocity and a direction to hit cell wall
	var angle = randf_range(0, 2*PI)
	var speed = randf_range(20, 50)
	lipid.linear_velocity = Vector2(cos(angle), sin(angle)) * speed
	
	get_parent().add_child(lipid)
