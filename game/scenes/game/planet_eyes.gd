extends Node2D

@onready var left_eye: Polygon2D = $LeftEye
@onready var right_eye: Polygon2D = $RightEye
@onready var left_pupil: Polygon2D = $LeftEye/LeftPupil
@onready var right_pupil: Polygon2D = $RightEye/RightPupil

var _blink_timer := 0.0
var _next_blink := 0.0
var _is_blinking := false
var _target_look_direction := Vector2.ZERO
var _current_look := Vector2.ZERO
var _is_dead := false

static var X_EYE_POLYGON := PackedVector2Array([
	Vector2(-6, -8), Vector2(-3, -8), Vector2(0, -3), Vector2(3, -8), Vector2(6, -8),
	Vector2(2, 0), Vector2(6, 8), Vector2(3, 8), Vector2(0, 3), Vector2(-3, 8), Vector2(-6, 8),
	Vector2(-2, 0)
])
static var NORMAL_EYE_POLYGON := PackedVector2Array([
	Vector2(-10, 0), Vector2(-7, -7), Vector2(0, -10), Vector2(7, -7), 
	Vector2(10, 0), Vector2(7, 7), Vector2(0, 10), Vector2(-7, 7)
])

func _ready() -> void:
	_schedule_next_blink()
	_update_eye_scale()

func _process(delta: float) -> void:
	if _is_dead:
		return
	_handle_blinking(delta)
	_handle_looking(delta)
	_update_eye_scale()

func _update_eye_scale() -> void:
	# based on planet size
	var planet: Planet = get_parent()
	if planet: # test
		var radius: float = C.PLANET_RADII[planet.tier]
		var eye_scale := radius / 60.0 # Normalize to a base size
		left_eye.scale = Vector2.ONE * eye_scale
		right_eye.scale = Vector2.ONE * eye_scale
		left_eye.position = Vector2(-radius * 0.3, -radius * 0.15)
		right_eye.position = Vector2(radius * 0.3, -radius * 0.15)

func _handle_blinking(delta: float) -> void:
	_blink_timer += delta
	
	if _is_blinking:
		if _blink_timer >= C.EYE_BLINK_DURATION:
			_is_blinking = false
			left_eye.scale.y = left_eye.scale.x
			right_eye.scale.y = right_eye.scale.x
			_schedule_next_blink()
	else:
		if _blink_timer >= _next_blink:
			_is_blinking = true
			_blink_timer = 0.0
			left_eye.scale.y = 0.1
			right_eye.scale.y = 0.1

func _schedule_next_blink() -> void:
	_blink_timer = 0.0
	_next_blink = randf_range(C.EYE_BLINK_INTERVAL_MIN, C.EYE_BLINK_INTERVAL_MAX)

func _handle_looking(delta: float) -> void:
	# Find nearest planet to look at
	var planet: Planet = get_parent()
	if not planet or not planet.has_been_shot:
		_target_look_direction = Vector2.ZERO
	else:
		var nearest := _find_nearest_planet(planet)
		if nearest:
			_target_look_direction = (nearest.global_position - planet.global_position).normalized()
		else:
			# Look toward center if no planets nearby
			_target_look_direction = (C.BUBBLE_CENTER - planet.global_position).normalized() * 0.3
	
	# Smooth look in direction
	_current_look = _current_look.lerp(_target_look_direction, delta * C.EYE_LOOK_SPEED)
	
	# Apply to pupils (offset within eye)
	var pupil_offset := _current_look * 3.0
	left_pupil.position = pupil_offset
	right_pupil.position = pupil_offset

func _find_nearest_planet(self_planet: Planet) -> Planet:
	var nearest: Planet = null
	var nearest_dist := 300.0 # Max look distance
	
	for node in get_tree().get_nodes_in_group("planets"):
		if node == self_planet or not node is Planet:
			continue
		var dist := self_planet.global_position.distance_to(node.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = node
	
	return nearest

func show_dead_eyes() -> void:
	if _is_dead:
		return
	_is_dead = true
	
	# Change eyes to X shape
	left_eye.polygon = X_EYE_POLYGON
	right_eye.polygon = X_EYE_POLYGON
	
	# Hide pupils
	left_pupil.visible = false
	right_pupil.visible = false

func show_normal_eyes() -> void:
	if not _is_dead:
		return
	_is_dead = false
	
	# Restore normal eye shape
	left_eye.polygon = NORMAL_EYE_POLYGON
	right_eye.polygon = NORMAL_EYE_POLYGON
	
	# Show pupils
	left_pupil.visible = true
	right_pupil.visible = true
	
	_schedule_next_blink()
