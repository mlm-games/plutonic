extends Control

const SETTINGS_MENU_SCENE = preload("res://addons/basic_settings_menu/settings_menu.tscn")

@onready var page_animator: PopupAnimator = $PopupAnimator
@onready var resume_button: Button = %ResumeButton

func _ready() -> void:
	visible = false
	A.tree.paused = false
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	%ResumeButton.pressed.connect(_on_resume_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%QuitButton.pressed.connect(_on_quit_button_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # Use a dedicated "pause" action in your project
		#if A.tree.paused: #causes other bugs, like unpausing in settings
			#unpause()
		#else:
		if not A.tree.paused: pause()
		%ResumeButton.grab_focus()
		get_viewport().set_input_as_handled()

func pause() -> void:
	A.tree.paused = true
	page_animator.animate_in()
	resume_button.grab_focus()

func unpause() -> void:
	# We unpause *after* the animation is done.
	page_animator.animate_out(Callable(self, "_on_unpause_animation_finished"))

func _on_unpause_animation_finished() -> void:
	A.tree.paused = false
	hide()
	
func _on_resume_button_pressed() -> void:
	unpause()

func _on_settings_button_pressed() -> void:
	#hide()
	var settings_instance = SETTINGS_MENU_SCENE.instantiate()
	add_child(settings_instance)
	
	# When the settings menu closes, we want the pause menu to reappear.
	#settings_instance.tree_exited.connect(show.bind(), CONNECT_ONE_SHOT)

func _on_quit_button_pressed() -> void:
	hide()
	A.tree.paused = false
	STransitions.change_scene_with_transition(C.SCREENS.MENU)
