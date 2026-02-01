## A collection of static functions for creating screen-wide visual effects.
##[br][br]
## Provides easy-to-use methods for common "juice" effects like camera shake,
## shader pulses, and impact flashes. All functions are static and can be
## called directly from the [code]ScreenEffects[/code] class without needing
## to instantiate it.
class_name ScreenEffects
extends RefCounted

static var _screen_shake_tween : Tween


## Shakes a [Camera2D] node with random offsets that decay over a set duration.
##[br][br]
## This is useful for adding impact to events like explosions or taking damage.
##[br]
## It works by creating a [Tween] that rapidly changes the camera's [member Camera2D.offset].
##[br]
## [param camera]: The [Camera2D] node to shake.
##[br]
## [param strength]: The maximum offset in pixels for the shake.
##[br]
## [param duration]: The total time in seconds the effect should last.
static func shake_camera(camera: Camera2D, strength: float = 10.0, duration: float = 0.2) -> void:
	_screen_shake_tween = camera.create_tween()
	var shake_count = int(duration * 60) # 60 shakes per second
	
	for i in shake_count:
		var decay = 1.0 - (float(i) / shake_count)
		var offset = Vector2(
			randf_range(-strength, strength) * decay,
			randf_range(-strength, strength) * decay
		)
		_screen_shake_tween.tween_property(camera, "offset", offset, 1.0/60.0)
	
	_screen_shake_tween.tween_property(camera, "offset", Vector2.ZERO, 1.0/60.0)


## Creates a brief chromatic aberration "pulse" effect using a shader.
##[br][br]
## [b]Setup Required:[/b] This function requires a [CanvasLayer] in your scene containing
## a [ColorRect] that fills the screen. This [ColorRect] must have a [ShaderMaterial]
## attached, with its shader set to [code]res://shaders/chromatic_aberration.gdshader[/code].
##[br][br]
## [param shader_material]: The [ShaderMaterial] containing the chromatic aberration shader.
##[br]
## [param duration]: The total time in seconds for the pulse.
##[br]
## [param strength]: The maximum strength of the color separation effect.
static func chromatic_aberration_pulse(shader_material: ShaderMaterial, duration: float = 0.3, strength: float = 15.0) -> Tween:
	if not shader_material or not shader_material.shader:
		push_error("Chromatic Aberration: Invalid ShaderMaterial provided.")
		return
	
	shader_material.shader = preload("uid://c07g25os2e3ln")

	var tween = shader_material.create_tween()
	tween.tween_property(shader_material, "shader_parameter/strength", strength, duration * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(shader_material, "shader_parameter/strength", 0.0, duration * 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	return tween


## Briefly flashes a [Node2D] or [Control] white to indicate a hit or interaction.
##[br][br]
## It automatically creates and assigns the required [ShaderMaterial] if the node
## does not already have one. Requires [code]res://shaders/flash_white.gdshader[/code].
##[br][br]
## [param node]: The [Node2D] or [Control] node to flash. The node must have a [member material] property.
##[br]
## [param duration]: The time in seconds for the flash to fade out.
static func flash_white(node: Node, duration: float = 0.1) -> Tween:
	if not node.has_method("get_material"):
		push_error("Node does not have a material property.")
		return
		
	var material = node.get_material()
	if not material is ShaderMaterial or not material.shader.resource_path.ends_with("flash_white.gdshader"):
		material = ShaderMaterial.new()
		material.shader = preload("uid://bf1q6g6cas62n")
		node.set_material(material)
	
	var tween = node.create_tween()
	tween.tween_method(func(value): material.set_shader_parameter("flash_amount", value), 1.0, 0.0, duration)
	return tween


## Pauses the entire game for a very short duration to add impact to an event.
##[br][br]
## [color=yellow]Warning:[/color] This function uses [code]await[/code], so the calling function must be marked
## with [code]async[/code]. It globally changes [member Engine.time_scale], which affects
## all physics and animations in the game. Use with very short durations.
##[br][br]
## [param duration]: The time in seconds to freeze the game. Should be a small value like 0.05.
##[br][br]
## [codeblock lang=gdscript]
## async func _on_bullet_impact():
##     ScreenEffects.freeze_frame(0.08)
##     # ...spawn explosion, deal damage, etc.
## [/codeblock]
static func freeze_frame(duration: float = 0.05) -> void:
	Engine.time_scale = 0.0
	await A.create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0


## Others


#hack: insert no of cycles formula/ use frequency instead of duration for another function called smooth screen shake?
static func screen_shake(duration: float, amplitude: float, camera: Camera2D = A.root.get_viewport().get_camera_2d()) -> void:
	_screen_shake_tween = Juice.create_global_tween()
	var original_position : Vector2 = camera.position
	for i in range(int(duration * 60)):  # Assuming 60 FPS
		var camera_offset : Vector2 = Vector2(randf() * amplitude * 2 - amplitude, 0)
		_screen_shake_tween.tween_property(camera, "position", original_position + camera_offset, 1.0 / 60)  # Tween for 1 frame
	_screen_shake_tween.tween_property(camera, "position", original_position, 1.0 / 60)  # Return to original position

# For use with anim_library (hit effect only)
static func hit_shake(amount: float = 10.0, duration: float = 0.2, camera: Camera2D = A.root.get_viewport().get_camera_2d()) -> void:
	_screen_shake_tween = Juice.create_global_tween(Tween.TRANS_SINE).set_parallel()
	
	camera.offset = Vector2.ZERO
	# Shake horizontally and vertically
	_screen_shake_tween.tween_property(camera, "offset:x", amount, duration * 0.25).from(0)
	_screen_shake_tween.tween_property(camera, "offset:y", amount * 0.6, duration * 0.25).from(0)
	
	# Smoothly return to center
	_screen_shake_tween.chain().tween_property(camera, "offset", Vector2.ZERO, duration * 0.75).set_trans(Tween.TRANS_CUBIC)

# For smoother screen shakes
static func camera_shake(intensity: float = 1.5, duration: float = 1.5, decay: float = 3.0, camera: Camera2D =  A.root.get_viewport().get_camera_2d()) -> void:
	# Stop any existing shake tweens
	
	_screen_shake_tween = A.create_tween()
	camera.set_meta("shake_tween", _screen_shake_tween)
	
	var original_position := camera.position
	var original_rotation := camera.rotation
	
	# This will be called by tween_method to update the camera shake
	var shake_function := func(progress: float) -> void:
		var remaining := 1.0 - progress
		var current_intensity := intensity * pow(remaining, decay)
		
		if current_intensity > 0.01:
			var cam_offset := Vector2(
				intensity * 5.0 * current_intensity * randf_range(-1, 1),
				intensity * 5.0 * current_intensity * randf_range(-1, 1)
			)
			var cam_rotation := 0.1 * intensity * current_intensity * randf_range(-1, 1)
			
			camera.position = original_position + cam_offset
			camera.rotation = original_rotation + cam_rotation
		else:
			camera.position = original_position
			camera.rotation = original_rotation
	
	#call our shake function over the duration
	_screen_shake_tween.tween_method(shake_function, 0.0, 1.0, duration)
	
	# Reset camera when done
	_screen_shake_tween.tween_callback(func() -> void:
		camera.position = original_position
		camera.rotation = original_rotation
	)

static func squash_simple(target: Object, x_force: float, y_force: float, duration: float = 0.3, trans_type: Tween.TransitionType = Tween.TRANS_QUAD, ) -> Tween:
	var tween : Tween =  A.create_tween()
	# initial squash
	tween.tween_property(target, "scale:x", 1 - x_force, duration/2).set_trans(trans_type).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(target, "scale:y", 1 + y_force, duration/2).set_trans(trans_type).set_ease(Tween.EASE_OUT)
	# return to normal
	tween.tween_property(target, "scale:x", 1, duration/2).set_trans(trans_type).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(target, "scale:y", 1, duration/2).set_trans(trans_type).set_ease(Tween.EASE_IN)
	return tween
