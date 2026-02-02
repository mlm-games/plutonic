extends Node2D #TODO: should change the restart button to AnimButton? Maybe no

@onready var bubble: Bubble = %Bubble
@onready var shooter: Shooter = %Shooter
@onready var hud: Control = $CanvasLayer/GameHUD
@onready var background: ColorRect = $Background

func _ready() -> void:
	_setup_background()
	GameManager.start_game()
	bubble.planet_escaped.connect(_on_planet_escaped)
	shooter.planet_shot.connect(_on_planet_shot)

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

func _on_planet_escaped(_planet: Planet) -> void:
	if GameManager.is_game_active:
		GameManager.end_game()
		_show_game_over()

func _on_planet_shot(_planet: Planet) -> void:
	hud.update_next_preview(shooter.get_next_planet_tier())

func _show_game_over() -> void:
	var game_over_screen := preload("res://game/scenes/ui/game_over_screen.tscn").instantiate()
	$CanvasLayer.add_child(game_over_screen)
