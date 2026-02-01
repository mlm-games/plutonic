class_name Bubble extends Node2D

signal planet_escaped(planet: Planet)
signal warning_state_changed(is_warning: bool)

@onready var bubble_visual: Sprite2D = $BubbleVisual
@onready var warning_area: Area2D = $WarningArea

var _planets_outside: Dictionary = {}  # Planet -> time_outside
var _is_warning_active := false

const NORMAL_MODULATE := Color(1, 1, 1, 1)
const WARNING_MODULATE := Color(1.2, 0.6, 0.6, 1)  # Red tint for warning

func _ready() -> void:
	_setup_collision()

func _setup_collision() -> void:
	# Warning area slightly larger than bubble
	var warning_shape := CircleShape2D.new()
	warning_shape.radius = C.BUBBLE_RADIUS + C.BOUNDARY_CHECK_MARGIN
	var collision := CollisionShape2D.new()
	collision.shape = warning_shape
	warning_area.add_child(collision)

func _physics_process(delta: float) -> void:
	_check_planets(delta)

func _check_planets(delta: float) -> void:
	var planets_in_danger := 0
	
	for planet: Planet in get_tree().get_nodes_in_group("planets"):
		if not planet.has_been_shot or not planet.has_collided_once:
			continue
		
		var distance := global_position.distance_to(planet.global_position)
		var planet_radius: float = C.PLANET_RADII[planet.tier]
		
		if distance + planet_radius > C.BUBBLE_RADIUS:
			# Planet is outside
			if not _planets_outside.has(planet):
				_planets_outside[planet] = 0.0
			_planets_outside[planet] += delta
			
			# Show dead eyes on planet
			if planet.eyes:
				planet.eyes.show_dead_eyes()
			
			# Check if in grace period (warning zone)
			if _planets_outside[planet] < C.GRACE_PERIOD:
				planets_in_danger += 1
			
			if _planets_outside[planet] >= C.GRACE_PERIOD:
				planet_escaped.emit(planet)
		else:
			# Planet is inside - reset eyes to normal
			if _planets_outside.has(planet) and planet.eyes:
				planet.eyes.show_normal_eyes()
			_planets_outside.erase(planet)
	
	# Update warning state and bubble color
	var should_warn := planets_in_danger > 0
	if should_warn != _is_warning_active:
		_is_warning_active = should_warn
		_update_visual_warning_state()

func is_position_inside(pos: Vector2, margin: float = 0.0) -> bool:
	return global_position.distance_to(pos) <= C.BUBBLE_RADIUS - margin

func _update_visual_warning_state() -> void:
	# Modulate bubble color based on warning state
	var target_modulate := WARNING_MODULATE if _is_warning_active else NORMAL_MODULATE
	
	# Tween the color change for smooth transition
	var tween := create_tween()
	tween.tween_property(bubble_visual, "modulate", target_modulate, 0.3)
	
	warning_state_changed.emit(_is_warning_active)
