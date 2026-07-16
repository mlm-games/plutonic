extends Node2D

@onready var bubble: Bubble = %Bubble
@onready var shooter: Shooter = %Shooter
@onready var hud: Control = $CanvasLayer/GameHUD
@onready var background: ColorRect = $Background

func _ready() -> void:
	_setup_background()
	GameManager.start_game(not GameManager.pending_load_data.is_empty())
	bubble.planet_escaped.connect(_on_planet_escaped)
	shooter.next_planet_tier_changed.connect(_on_next_planet_tier_changed)
	shooter.planet_shot.connect(_on_planet_shot)

	if not GameManager.pending_load_data.is_empty():
		_restore_game_state(GameManager.pending_load_data)
		GameManager.load_game_state_into_scene()

	hud.update_next_preview(shooter.get_next_planet_tier())

	var save_timer = Timer.new()
	save_timer.wait_time = 15.0
	save_timer.timeout.connect(GameManager.save_game_state)
	save_timer.autostart = true
	add_child(save_timer)

func _setup_background() -> void:
	background.color = Color(0.05, 0.05, 0.15)
	
	# stars (Good enough)
	for i in 100:
		var star := Polygon2D.new()
		star.polygon = PackedVector2Array([
			Vector2(-1, 0), Vector2(0, -1), Vector2(1, 0), Vector2(0, 1)
		])
		star.color = Color(1, 1, 1, randf_range(0.3, 0.8))
		star.position = Vector2(randf() * 1080, randf() * 1920)
		star.scale = Vector2.ONE * randf_range(0.5, 2.0)
		background.add_child(star)

func _physics_process(_delta: float) -> void:
	_apply_central_gravity()

func _apply_central_gravity() -> void:
	for planet : Planet in get_tree().get_nodes_in_group("planets"):
		if not planet.has_been_shot:
			continue
		
		var to_center := C.BUBBLE_CENTER - planet.global_position
		var distance := to_center.length()
		
		if distance > 1.0:  # division by zero exception
			var gravity_direction := to_center.normalized()
			var gravity_force := gravity_direction * C.GRAVITY_STRENGTH * planet.mass
			#planet.apply_central_force(gravity_force)
			planet.apply_central_force(Vector2(gravity_force.x, gravity_force.y/1.2))

func _restore_game_state(data: Dictionary) -> void:
	for p in get_tree().get_nodes_in_group("planets"):
		if p.get_parent() != shooter.current_planet_holder:
			p.queue_free()

	shooter.restore_from_save(data)

	for p_data in data.get("planets", []):
		var planet = preload("res://game/scenes/game/planet.tscn").instantiate()
		planet.add_to_group("planets")
		add_child(planet)
		planet.global_position = Vector2(p_data.pos_x, p_data.pos_y)
		planet.tier = p_data.tier
		planet.has_been_shot = p_data.get("has_been_shot", true)
		planet.has_collided_once = p_data.get("has_collided_once", true)
		planet.rotation = p_data.get("rot", 0.0)
		planet.freeze = false
		planet.set_deferred("linear_velocity", Vector2(p_data.vel_x, p_data.vel_y))
		planet.set_deferred("angular_velocity", p_data.get("ang_vel", 0.0))

	hud.update_next_preview(shooter.next_planet_tier)

func _on_planet_shot(_planet: Planet) -> void:
	GameManager.save_game_state()

func _on_planet_escaped(_planet: Planet) -> void:
	if GameManager.is_game_active:
		GameManager.end_game()
		_show_game_over()

func _on_next_planet_tier_changed(tier: int) -> void:
	hud.update_next_preview(tier)

func _show_game_over() -> void:
	var game_over_screen := preload("res://game/scenes/ui/game_over_screen.tscn").instantiate()
	$CanvasLayer.add_child(game_over_screen)
