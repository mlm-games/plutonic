extends Node

signal fullscreen_changed(is_fullscreen: bool)

var _stored_position: Vector2i
var _stored_size: Vector2i

func _input(event):
	if not OS.get_name() in ["Windows", "macOS", "Linux"] or OS.has_feature("web"):
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F11:
				toggle_fullscreen()
				#NOTE: to be changed based on pause menu
			#KEY_ESCAPE: # If you do not use esc for pausing the game
				#get_tree().root.add_child(preload("res://addons/basic_settings_menu/settings_menu.tscn").instantiate())

func toggle_fullscreen():
	if is_fullscreen():
		exit_fullscreen()
	else:
		enter_fullscreen()

func enter_fullscreen():
	_store_window_state()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	fullscreen_changed.emit(true)

func exit_fullscreen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	_restore_window_state()
	fullscreen_changed.emit(false)

func is_fullscreen() -> bool:
	return DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN, DisplayServer.WINDOW_MODE_FULLSCREEN]

func _store_window_state():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		_stored_position = DisplayServer.window_get_position()
		_stored_size = DisplayServer.window_get_size()

func _restore_window_state():
	if _stored_size != Vector2i.ZERO:
		DisplayServer.window_set_position(_stored_position)
		DisplayServer.window_set_size(_stored_size)
