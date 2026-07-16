class_name Menu extends Control


func _ready() -> void:
	%PlayButton.grab_focus()
	
	%PlayButton.pressed.connect(_on_new_game)
	%ContinueButton.visible = GameManager.has_game_save()
	%ContinueButton.pressed.connect(_on_continue)
	%CreditsButton.pressed.connect(STransitions.change_scene_with_transition.bind(C.SCREENS.CREDITS))
	
	%QuitButton.pressed.connect(get_tree().quit)

func _on_new_game() -> void:
	GameManager.clear_game_save()
	STransitions.change_scene_with_transition(C.SCREENS.GAME)

func _on_continue() -> void:
	GameManager.prepare_continue()
	STransitions.change_scene_with_transition(C.SCREENS.GAME)
	
