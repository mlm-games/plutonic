## A collection of static functions to add polish and "juice" to UI elements.
##[br][br]
## Provides easy-to-use methods for common UI animations like hover effects,
## typewriter text reveals, and number counters.
class_name UIEffects
extends RefCounted


## Connects signals to a [BaseButton] to make it scale up on hover.
##[br][br]
## A simple, fire-and-forget way to make buttons more interactive.
##[br]
## It connects to the [signal BaseButton.mouse_entered] and [signal BaseButton.mouse_exited]
## signals of the button to trigger the animations.
##[br]
## [param button]: The button ([Button], [TextureButton], etc.) to apply the effect to.
##[br]
## [param scale_amount]: The amount to scale the button on hover (e.g., 1.1 is 110%).
static func setup_hover_scale(button: BaseButton, scale_amount: float = 1.1) -> void:
	var original_scale = button.scale
	button.mouse_entered.connect(func():
		var tween = button.create_tween()
		tween.tween_property(button, "scale", original_scale * scale_amount, 0.1).set_trans(Tween.TRANS_SINE)
	)
	button.mouse_exited.connect(func():
		var tween = button.create_tween()
		tween.tween_property(button, "scale", original_scale, 0.1).set_trans(Tween.TRANS_SINE)
	)


## Animates the text in a [RichTextLabel] to appear one character at a time.
##[br][br]
## It works by tweening the [member RichTextLabel.visible_ratio] property.
##[br]
## [param label]: The [RichTextLabel] to animate.
##[br]
## [param speed]: The time in seconds to wait between each character appearing.
static func typewriter_effect(label: RichTextLabel, speed: float = 0.05) -> Tween:
	label.visible_ratio = 0.0
	var tween = label.create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, label.get_text().length() * speed).set_trans(Tween.TRANS_LINEAR)
	return tween


## Animates the text of a [Label] to count from one number to another.
##[br][br]
## Useful for score counters or health bars that update visually.
##[br]
## [param label]: The [Label] node whose text will be updated.
##[br]
## [param from]: The integer value to start counting from.
##[br]
## [param to]: The integer value to count to.
##[br]
## [param duration]: The total time in seconds for the count animation.
static func animate_number(label: Label, from: int, to: int, duration: float = 1.0) -> Tween:
	var tween = label.create_tween()
	tween.tween_method(func(value): label.text = str(int(value)), float(from), float(to), duration)
	return tween


## Creates a pulsing glow effect on a [Control] node using a shader.
##[br][br]
## [b]Setup Required:[/b] The target [param node] must have a [ShaderMaterial] attached
## with a shader that has a [code]glow_strength[/code] uniform.
##[br]
## Example shader: [code]res://shaders/ui_glow.gdshader[/code].
##[br]
## [param node]: The [Control] node to apply the effect to.
##[br]
## [param color]: The color of the glow (requires a corresponding uniform in the shader).
##[br]
## [param duration]: The duration of one full pulse cycle (glow in and out).
static func pulse_glow(node: Control, color: Color = Color.WHITE, duration: float = 1.0) -> Tween:
	if not node.material or not node.material is ShaderMaterial:
		push_warning("UIEffects.pulse_glow requires the node to have a ShaderMaterial.")
		node.material = ShaderMaterial.new()
		# ui_glow.gdshader
		node.material.shader = preload("uid://c5tus8tbloipg")
		return

	# This line is an example; your shader might have different parameter names.
	node.material.set_shader_parameter("glow_color", color)
	
	var tween = node.create_tween()
	tween.set_loops()
	tween.tween_property(node.material, "shader_parameter/glow_strength", 1.0, duration * 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node.material, "shader_parameter/glow_strength", 0.0, duration * 0.5).set_trans(Tween.TRANS_SINE)
	return tween
