class_name Menu extends Control


func _ready() -> void:
	%PlayButton.grab_focus()
	
	%PlayButton.pressed.connect(STransitions.change_scene_with_transition.bind(C.SCREENS.GAME))
	#%SettingsButton.pressed.connect(add_child.bind(preload("uid://dp42fom7cc3n0").instantiate()))
	%CreditsButton.pressed.connect(STransitions.change_scene_with_transition.bind(C.SCREENS.CREDITS))
	
	%QuitButton.pressed.connect(get_tree().quit)
	
