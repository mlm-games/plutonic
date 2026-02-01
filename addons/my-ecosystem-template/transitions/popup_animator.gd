class_name PopupAnimator extends Node

@export var target_node: CanvasItem

@export_group("Animation Properties")
@export var transition_duration: float = 0.2
@export var transition_scale: float = 0.95
@export var transition_type: Tween.TransitionType = Tween.TRANS_CUBIC
@export var ease_type_in: Tween.EaseType = Tween.EASE_OUT
@export var ease_type_out: Tween.EaseType = Tween.EASE_IN

var _active_tween: Tween

func _ready() -> void:
	if not target_node:
		target_node = get_parent()
	
	assert(target_node is CanvasItem, "PopupAnimator's target_node must be a CanvasItem.")
	

func animate_in() -> void:
	target_node.scale = Vector2.ONE * transition_scale
	target_node.modulate = Color.TRANSPARENT
	target_node.visible = true

	_active_tween = target_node.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	_active_tween.tween_property(target_node, "scale", Vector2.ONE, transition_duration)\
		.set_trans(transition_type).set_ease(ease_type_in)
		

	_active_tween.parallel().tween_property(target_node, "modulate", Color.WHITE, transition_duration)

func animate_out(on_finish: Callable = Callable()) -> void:
	_active_tween = target_node.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	_active_tween.tween_property(target_node, "scale", Vector2.ONE * transition_scale, transition_duration)\
		.set_trans(transition_type).set_ease(ease_type_out)
		

	_active_tween.parallel().tween_property(target_node, "modulate", Color.TRANSPARENT, transition_duration)

	if on_finish.is_valid():
		_active_tween.tween_callback(on_finish)
