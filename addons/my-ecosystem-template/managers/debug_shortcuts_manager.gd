#class_name DebugShortcutsManager
extends Node


func _unhandled_input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey and event.pressed:
			match event.keycode:
				KEY_R:
					get_tree().reload_current_scene()
				KEY_EQUAL:
					Engine.time_scale += 1
				KEY_MINUS:
					Engine.time_scale -= 1
				# Controlling camera can be done easily via the options in debug menu
