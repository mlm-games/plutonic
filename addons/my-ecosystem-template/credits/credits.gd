extends Control

func _ready() -> void:
	#%ExitButton.pressed.connect(Transitions.change_scene_with_transition.bind(ProjectSettings.get_setting("application/run/main_scene")))
	$PopupAnimator.animate_in()
	%ExitButton.grab_focus()
