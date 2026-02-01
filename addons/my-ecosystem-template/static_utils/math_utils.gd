## A collection of static utility functions for common mathematical operations.
##[br][br]
## Provides useful functions for smoothing, approaching values, and creating
## oscillating motion that are not built into GDScript by default.
class_name MathUtils
extends RefCounted


## Gradually changes a value towards a desired goal over time.
##[br][br]
## This function is an implementation of the smooth damping function often found in
## other game engines. It's useful for creating smooth camera followers or other
## objects that need to chase a target without snapping. It must be called every frame.
##[br][br]
## Returns a [Dictionary] containing the new value and the new velocity:
## [code]{ "value": new_current, "velocity": new_velocity }[/code].
##[br][br]
## [codeblock lang=gdscript]
## var camera_x_velocity = 0.0
##
## func _process(delta):
##     var result = MathUtils.smooth_damp(
##         global_position.x,
##         player.global_position.x,
##         camera_x_velocity,
##         0.25,
##         delta
##     )
##     global_position.x = result.value
##     camera_x_velocity = result.velocity
## [/codeblock]
static func smooth_damp(current: float, target: float, current_velocity: float, smooth_time: float, delta: float) -> Dictionary:
	smooth_time = max(0.0001, smooth_time)
	var omega = 2.0 / smooth_time
	var x = omega * delta
	var exp = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var change = current - target
	var temp = (current_velocity + omega * change) * delta
	current_velocity = (current_velocity - omega * temp) * exp
	var output = target + (change + temp) * exp
	
	return {"value": output, "velocity": current_velocity}


## Moves a value towards a target at a maximum rate.
##[br][br]
## Unlike a lerp, this function moves the value by a fixed step, which is useful
## when you want a constant speed of change.
##[br]
## [param current]: The current value.
##[br]
## [param target]: The value to move towards.
##[br]
## [param rate]: The maximum amount to change the value by in one call.
static func approach(current: float, target: float, rate: float) -> float:
	if current < target:
		return min(current + rate, target)
	else:
		return max(current - rate, target)


## Creates a sinusoidal wave oscillation between two values over time.
##[br][br]
## This is useful for creating effects like floating items, pulsing lights, or
## any other cyclic motion.
##[br]
## [param from]: The minimum value of the wave.
##[br]
## [param to]: The maximum value of the wave.
##[br]
## [param duration]: The time in seconds for one full cycle of the wave.
##[br]
## [param offset]: A time offset in seconds to start the wave at a different point in its cycle.
static func wave(from: float, to: float, duration: float, offset: float = 0.0) -> float:
	if duration == 0.0: return from
	var t = (Time.get_ticks_msec() / 1000.0 + offset) / duration
	return from + (to - from) * (sin(t * TAU) + 1.0) * 0.5
