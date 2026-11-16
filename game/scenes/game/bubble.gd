class_name Bubble extends Node2D

signal planet_escaped(planet: Planet)
signal warning_state_changed(is_warning: bool)

@onready var bubble_visual: Sprite2D = $BubbleVisual
@onready var warning_area: Area2D = $WarningArea

var radius := C.BUBBLE_RADIUS

var _planets_outside: Dictionary = {}  # Planet -> time_outside
var _escaped_planets: Dictionary = {}
var _is_warning_active := false
var _base_visual_scale := Vector2.ONE
var _target_radius := C.BUBBLE_RADIUS
var _expand_tween: Tween = null
var _warning_shape: CircleShape2D = null

const NORMAL_MODULATE := Color(1, 1, 1, 1)
const WARNING_MODULATE := Color(1.2, 0.6, 0.6, 1)  # Red tint for warning

func _ready() -> void:
	_base_visual_scale = bubble_visual.scale
	_setup_collision()
	_apply_radius()

func _setup_collision() -> void:
	# Warning area slightly larger than bubble
	_warning_shape = CircleShape2D.new()
	_warning_shape.radius = radius + C.BOUNDARY_CHECK_MARGIN
	var collision := CollisionShape2D.new()
	collision.shape = _warning_shape
	warning_area.add_child(collision)

func _physics_process(delta: float) -> void:
	_check_planets(delta)

func _check_planets(delta: float) -> void:
	var planets_in_danger := 0
	var largest_tier := 0
	_cleanup_planets()
	
	for planet: Planet in get_tree().get_nodes_in_group("planets"):
		if not planet.has_been_shot:
			continue
		largest_tier = maxi(largest_tier, planet.tier)
		
		var distance := global_position.distance_to(planet.global_position)
		var planet_radius: float = C.PLANET_RADII[planet.tier]
		var outside := distance + planet_radius > radius
		
		if outside:
			if not planet.touching.is_empty():
				# Planet is outside
				if not _planets_outside.has(planet):
					_planets_outside[planet] = 0.0
				if planet.touching.size() > 1:
					_planets_outside[planet] += delta
				else:
					_planets_outside[planet] = 0

				# Show dead eyes on planet
				if planet.eyes:
					planet.eyes.show_dead_eyes()

				# Check if in grace period (warning zone)
				if _planets_outside[planet] < C.GRACE_PERIOD:
					planets_in_danger += 1
				elif not _escaped_planets.has(planet):
					_escaped_planets[planet] = true
					planet_escaped.emit(planet)
			else:
				if _planets_outside.has(planet):
					_planets_outside[planet] = 0.0
				if _escaped_planets.has(planet) and planet.eyes:
					planet.eyes.show_dead_eyes()
		else:
			# Planet is inside - reset eyes to normal
			if _planets_outside.has(planet) and planet.eyes:
				planet.eyes.show_normal_eyes()
			_planets_outside.erase(planet)
			_escaped_planets.erase(planet)
	
	# Update warning state and bubble color
	var should_warn := planets_in_danger > 0 or not _escaped_planets.is_empty()
	if should_warn != _is_warning_active:
		_is_warning_active = should_warn
		_update_visual_warning_state()

	_expand_for_tier(largest_tier)

func _cleanup_planets() -> void:
	for planet in _planets_outside.keys():
		if not is_instance_valid(planet):
			_planets_outside.erase(planet)
	for planet in _escaped_planets.keys():
		if not is_instance_valid(planet):
			_escaped_planets.erase(planet)

func _expand_for_tier(tier: int) -> void:
	var target := C.bubble_radius_for_tier(tier)
	if target <= _target_radius:
		return

	_target_radius = target
	if _expand_tween:
		_expand_tween.kill()
	_expand_tween = create_tween()
	_expand_tween.tween_method(_set_radius, radius, target, C.BUBBLE_EXPAND_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _set_radius(value: float) -> void:
	radius = value
	_apply_radius()

func _apply_radius() -> void:
	bubble_visual.scale = _base_visual_scale * (radius / C.BUBBLE_RADIUS)
	if _warning_shape:
		_warning_shape.radius = radius + C.BOUNDARY_CHECK_MARGIN

func has_escaped_planets() -> bool:
	for planet in _escaped_planets:
		if is_instance_valid(planet):
			return true
	return false

func get_target_radius() -> float:
	return _target_radius

func restore_radius(value: float) -> void:
	var saved_radius := clampf(value, C.BUBBLE_RADIUS, C.bubble_radius_for_tier(C.PlanetType.SUN))
	if saved_radius <= _target_radius:
		return
	if _expand_tween:
		_expand_tween.kill()
		_expand_tween = null
	_target_radius = saved_radius
	_set_radius(saved_radius)

func is_position_inside(pos: Vector2, margin: float = 0.0) -> bool:
	return global_position.distance_to(pos) <= radius - margin

func _update_visual_warning_state() -> void:
	# Modulate bubble color based on warning state
	var target_modulate := WARNING_MODULATE if _is_warning_active else NORMAL_MODULATE
	
	# Tween the color change for smooth transition
	var tween := create_tween()
	tween.tween_property(bubble_visual, "modulate", target_modulate, 0.3)
	
	warning_state_changed.emit(_is_warning_active)
