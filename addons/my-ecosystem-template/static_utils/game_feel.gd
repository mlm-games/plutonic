## A collection of static functions focused on "game feel" and player feedback.
##[br][br]
## Provides methods for creating physical-feeling feedback like recoil, knockback,
## time manipulation, and controller vibration.
class_name GameFeel
extends RefCounted


## Adds a positional recoil effect to a [Node2D].
##[br][br]
## The node is instantly pushed back in the given direction and then smoothly
## tweens back to its original position. Ideal for weapon firing effects.
##[br]
## [param node]: The [Node2D] to apply the recoil to (e.g., a weapon sprite).
##[br]
## [param direction]: A normalized [Vector2] indicating the direction of the recoil push.
##[br]
## [param strength]: The distance in pixels to push the node back.
static func add_recoil(node: Node2D, direction: Vector2, strength: float = 10.0) -> Tween:
	var original_pos = node.position
	node.position += direction * strength
	
	var tween = node.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(node, "position", original_pos, 0.2)
	return tween


## Applies a knockback force to a [CharacterBody2D] by setting its velocity.
##[br][br]
## [b]Note:[/b] This function assumes the target body's script will handle friction
## and gravity in its [code]_physics_process[/code] function to slow the body down
## after the initial velocity is set.
##[br]
## [param body]: The [CharacterBody2D] to knock back.
##[br]
## [param direction]: A normalized [Vector2] indicating the direction of the knockback.
##[br]
## [param force]: The magnitude of the velocity to apply.
static func apply_knockback(body: CharacterBody2D, direction: Vector2, force: float = 300.0) -> void:
	body.velocity = direction * force


## Creates a slow-motion effect for a specific duration.
##[br][br]
## This function slows down the entire game by changing [member Engine.time_scale].
## It then smoothly tweens the time scale back to normal.
##[br]
## [color=yellow]Warning:[/color] This function uses [code]await[/code], so the calling function
## must be marked with [code]async[/code].
##[br]
## [param time_scale]: The target time scale (e.g., 0.5 for 50% speed).
##[br]
## [param duration]: The duration in [b]real-time[/b] seconds that the effect should last before starting to return to normal.
static func slow_motion(time_scale: float = 0.3, duration: float = 0.5) -> Tween:
	Engine.time_scale = time_scale
	# The timer must be process-agnostic to work correctly when time_scale is low or zero.
	await A.create_timer(duration, true, false, true).timeout
	
	var tween = A.create_tween()
	tween.tween_property(Engine, "time_scale", 1.0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	return tween


## Vibrates a connected controller.
##[br][br]
## Uses Godot's built-in joystick vibration system.
##[br]
## [param player_id]: The ID of the player/controller to rumble (usually 0 for the first player).
##[br]
## [param weak]: The intensity of the weak motor (0.0 to 1.0).
##[br]
## [param strong]: The intensity of the strong motor (0.0 to 1.0).
##[br]
## [param duration]: The duration of the vibration in seconds.
static func rumble_controller(player_id: int = 0, weak: float = 0.5, strong: float = 0.5, duration: float = 0.2) -> void:
	Input.start_joy_vibration(player_id, weak, strong, duration)
