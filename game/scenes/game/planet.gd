class_name Planet extends RigidBody2D

signal merged(resulting_tier: int)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Sprite2D = $Visual
@onready var eyes: Node2D = $Eyes

var tier: int = 0: set = set_tier
var is_merging := false
var has_been_shot := false 
var has_collided_once := false

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

func set_tier(value: int) -> void:
	tier = clampi(value, 0, C.PlanetType.SUN)
	_update_visuals()

func _update_visuals() -> void:
	var radius: float = C.PLANET_RADII[tier]
	
	# Unique collision shape (so that it is not shared among all planets)
	var circle := CircleShape2D.new()
	circle.radius = radius
	collision_shape.set_deferred("shape", circle)
	
	var texture_path := C.PLANET_TEXTURES[tier]
	var texture := load(texture_path) as Texture2D
	if texture:
		visual.texture = texture
		# SVG is 200x with 90px radius, so scale = radius / 90
		var scale_factor := radius / 90.0
		visual.scale = Vector2(scale_factor, scale_factor)
		#if tier == C.PlanetType.SATURN:
			#visual.scale.x = scale_factor * (280.0 / 200.0)
	
	# Update physics
	var area := PI * radius * radius
	mass = area * C.PLANET_DENSITY * 0.001 # Reduce 
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = C.PLANET_FRICTION
	physics_material_override.bounce = C.PLANET_BOUNCE

func _on_body_entered(other: Node) -> void:
	if is_merging or not has_been_shot:
		return
	if other is Planet and other.has_been_shot and not other.is_merging:
		has_collided_once = true
		if other.tier == tier and tier < C.PlanetType.SUN:
			_attempt_merge(other)

func _attempt_merge(other: Planet) -> void:
	# Ensure only one planet handles the merge (very rarely causes issues, where 2 of same size do not merge)
	if get_instance_id() < other.get_instance_id():
		return
	
	is_merging = true
	other.is_merging = true
	
	var merge_position := (global_position + other.global_position) / 2.0
	var new_tier := tier + 1
	
	_spawn_merge_particles(merge_position, new_tier)
	
	other.queue_free()
	
	global_position = merge_position
	tier = new_tier
	is_merging = false
	
	merged.emit(new_tier)
	GameManager.add_score(new_tier)
	
	if new_tier == C.PlanetType.SUN:
		GameManager.notify_sun_created()

func _spawn_merge_particles(pos: Vector2, _new_tier: int) -> void:
	var particles := preload("res://game/scenes/game/merge_particles.tscn").instantiate()
	particles.global_position = pos
	#Extra?: particles.modulate = C.PLANET_COLORS[new_tier]
	get_tree().current_scene.add_child(particles)

func release_into_play() -> void:
	has_been_shot = true
	freeze = false
