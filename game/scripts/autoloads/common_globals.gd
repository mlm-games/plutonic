extends Node

func _input(event):
	if OS.get_name() in ["Windows", "macOS", "Linux"] and not OS.has_feature("web"):
		if event is InputEventKey:
			if event.keycode == KEY_F11 and event.pressed:
				if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
				elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	#if event.is_action_pressed("undo"):
		#UndoRedoManager.undo()
	#else:
		#UndoRedoManager.redo()
