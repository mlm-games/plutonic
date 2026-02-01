## A collection of static functions for procedural "juicy" animations on nodes.
##
## Adds life to UI elements and game objects with common animation patterns li[br][br]ke
## bouncing, squashing, and popping. These functions create and manage their own
## [Tween]s, making them fire-and-forget.
class_name Juice
extends RefCounted


## Makes a [Node2D] quickly scale up past its original size and then bounce back elastically.
##[br][br]
## Ideal for when an item is collected or a button is pressed.
##[br]
## [param node]: The [Node2D] to animate.
##[br]
## [param scale_amount]: The multiplier for the peak scale (e.g., 1.2 means 120% of original size).
##[br]
## [param duration]: The total time in seconds for the animation.
static func bounce_scale(node: Node2D, scale_amount: float = 1.2, duration: float = 0.3) -> Tween:
	var original_scale = node.scale
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(node, "scale", original_scale * scale_amount, duration * 0.3)
	tween.tween_property(node, "scale", original_scale, duration * 0.7)
	return tween


## Applies a classic squash and stretch animation to a [Node2D].
##[br][br]
## Useful for character landings, impacts, or any springy motion.
##[br]
## [param node]: The [Node2D] to animate.
##[br]
## [param squash_amount]: A [Vector2] that defines the scale multiplier on the x and y axes.
##[br]
## [param duration]: The total time in seconds for the animation.
static func squash_stretch(node: Node2D, squash_amount: Vector2 = Vector2(1.3, 0.7), duration: float = 0.2) -> Tween:
	var original_scale = node.scale
	var tween = node.create_tween()
	tween.tween_property(node, "scale", original_scale * squash_amount, duration * 0.5)
	tween.tween_property(node, "scale", original_scale, duration * 0.5)
	return tween


## Makes a [Node2D] appear by scaling it up from a smaller size with an overshoot effect.
##[br][br]
## Great for UI elements or items spawning into the world. Uses [code]TRANS_BACK[/code] easing.
##[br]
## [param node]: The [Node2D] to animate.
##[br]
## [param duration]: The total time in seconds for the animation.
##[br]
## [param from_scale]: The initial scale multiplier (0.0 means it starts invisible).
static func pop_in(node: Node2D, duration: float = 0.3, from_scale: float = 0.0) -> Tween:
	var target_scale = node.scale
	node.scale = target_scale * from_scale
	
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "scale", target_scale, duration)
	return tween


## Briefly wobbles a [Node2D] left and right by tweening its rotation.
##[br][br]
## Can be used to draw attention to an element when hovered or selected.
##[br]
## [param node]: The [Node2D] to animate.
##[br]
## [param amount]: The maximum rotation in degrees for the wobble.
##[br]
## [param duration]: The total time in seconds for the animation.
static func wobble(node: Node2D, amount: float = 10.0, duration: float = 0.5) -> Tween:
	var tween = node.create_tween()
	tween.set_loops(2)
	tween.tween_property(node, "rotation_degrees", amount, duration * 0.25)
	tween.tween_property(node, "rotation_degrees", -amount, duration * 0.25)
	tween.finished.connect(func(): node.rotation_degrees = 0)
	return tween


## Better used for setting ui label values like currency? 
static func set_tweened_value(node: Node, property: NodePath, val: Variant, dur: float = 0.1, trans := Tween.TRANS_CUBIC, ease := Tween.EASE_IN_OUT, ignore_time_scale := true, pause_mode := Tween.TWEEN_PAUSE_PROCESS) -> Tween:
	var tween : Tween =  create_global_tween(trans).set_ease(ease).set_ignore_time_scale(ignore_time_scale).set_pause_mode(pause_mode)
	tween.tween_property(node, property, val, dur)
	return tween


static func create_global_tween(trans := Tween.TRANS_CUBIC) -> Tween:
	return A.create_tween().set_trans(Tween.TRANS_CUBIC)
