class_name Shooter extends Node2D

signal planet_shot(planet: Planet)
signal next_planet_tier_changed(tier)

@onready var trajectory_line: Line2D = $TrajectoryLine
@onready var current_planet_holder: Node2D = $CurrentPlanetHolder
@onready var aim_indicator: Polygon2D = $AimIndicator

var current_planet: Planet = null
var next_planet_tier: int = 0:
	set(val): next_planet_tier = val; next_planet_tier_changed.emit(val)

var is_aiming := false
var aim_start_pos := Vector2.ZERO
var aim_current_pos := Vector2.ZERO

const SHOOTER_DISTANCE := 480.0  # Distance from bubble center
const TRAJECTORY_SEGMENTS := 20
const TRAJECTORY_TIME := 0.8

func _ready() -> void:
	trajectory_line.visible = false
	
	next_planet_tier = _get_random_spawn_tier()
	_spawn_next_planet()
	

func _spawn_next_planet() -> void:
	# favor smaller ones (make it favor lager ones later in-game)

	current_planet = preload("res://game/scenes/game/planet.tscn").instantiate()
	current_planet.freeze = true
	current_planet.add_to_group("planets")
	current_planet_holder.add_child(current_planet)
	current_planet.tier = next_planet_tier

	next_planet_tier = _get_random_spawn_tier()

func _get_random_spawn_tier() -> int:
	var weights := [40, 30, 15, 10, 5]  # Pluto, Moon, Mercury, Mars, Venus
	var total := 0
	for w in weights:
		total += w

	var roll := randi() % total
	var cumulative := 0
	for i in weights.size():
		cumulative += weights[i]
		if roll < cumulative:
			return i
	return 0

func get_next_planet_tier() -> int:
	return next_planet_tier

func _input(event: InputEvent) -> void:
	if not GameManager.is_game_active or current_planet == null:
		return

	if event is InputEventMouseButton or event is InputEventScreenTouch:
		var pressed: bool = event.pressed if event is InputEventMouseButton else event.pressed
		var pos: Vector2 = event.position

		if pressed:
			_start_aim(pos)
		else:
			if is_aiming:
				_release_shot()

	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		if is_aiming:
			var pos: Vector2 = event.position
			_update_aim(pos)

func _start_aim(pos: Vector2) -> void:
	is_aiming = true
	aim_start_pos = pos
	aim_current_pos = pos
	trajectory_line.visible = true

func _update_aim(pos: Vector2) -> void:
	aim_current_pos = pos
	_update_trajectory()

func _release_shot() -> void:
	is_aiming = false
	trajectory_line.visible = false

	var direction := (aim_start_pos - aim_current_pos).normalized()
	var power := clampf(aim_start_pos.distance_to(aim_current_pos) / 200.0, 0.1, 1.0)

	if direction.length() < 0.1:
		##TESTING_ONLY: No real aim, shoots toward center
		#direction = (C.BUBBLE_CENTER - global_position).normalized()
		#power = 0.5
		return

	_shoot(direction, power)

func _shoot(direction: Vector2, power: float) -> void:
	if current_planet == null:
		return

	current_planet_holder.remove_child(current_planet)
	get_tree().current_scene.add_child(current_planet)
	current_planet.global_position = global_position

	var force := direction * C.SHOOT_FORCE * power * current_planet.mass
	current_planet.release_into_play()
	current_planet.apply_central_impulse(force)

	planet_shot.emit(current_planet)
	current_planet = null

	get_tree().create_timer(0.3).timeout.connect(_spawn_next_planet)

func _update_trajectory() -> void:
	var direction := (aim_start_pos - aim_current_pos).normalized()
	var power := clampf(aim_start_pos.distance_to(aim_current_pos) / 200.0, 0.1, 1.0)

	if direction.length() < 0.1:
		trajectory_line.clear_points()
		return

	var velocity := direction * C.SHOOT_FORCE * power
	var points := PackedVector2Array()
	var sim_pos := global_position
	var sim_vel := velocity
	var dt := TRAJECTORY_TIME / TRAJECTORY_SEGMENTS

	for i in TRAJECTORY_SEGMENTS:
		points.append(sim_pos - global_position)  # Local coords

		# Simulate gravity toward center
		var to_center := C.BUBBLE_CENTER - sim_pos
		var gravity_force := to_center.normalized() * C.GRAVITY_STRENGTH

		sim_vel += gravity_force * dt
		sim_pos += sim_vel * dt

	trajectory_line.points = points

func set_shooter_angle(angle: float) -> void:
	var offset := Vector2(cos(angle), sin(angle)) * SHOOTER_DISTANCE
	global_position = C.BUBBLE_CENTER + offset
	rotation = angle + PI / 2  # toward center
