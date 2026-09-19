extends Control

@onready var final_score_label: Label = %FinalScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var new_best_label: Label = %NewBestLabel
@onready var restart_button: Button = %RestartButton
@onready var share_button: Button = %ShareButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	final_score_label.text = tr("GAME_OBJECTIVE_SCORE") + ": %d" % GameManager.score
	high_score_label.text = tr("GAME_OBJECTIVE_HIGH_SCORE") + ": %d" % GameManager.high_score
	new_best_label.visible = GameManager.is_new_best()
	
	restart_button.pressed.connect(_on_restart)
	share_button.pressed.connect(_on_share)
	menu_button.pressed.connect(_on_menu)
	
	restart_button.grab_focus()

func _on_restart() -> void:
	GameManager.start_game(false)
	get_tree().reload_current_scene()

func _on_share() -> void:
	var text := GameManager.get_share_text()

	if OS.has_feature("web"):
		var escaped := text.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n")
		JavaScriptBridge.eval("navigator.clipboard.writeText('%s')" % escaped)
	else:
		DisplayServer.clipboard_set(text)

	share_button.text = tr("MENU_LABEL_SHARE") + "..."
	get_tree().create_timer(1.5).timeout.connect(func(): share_button.text = tr("MENU_LABEL_SHARE"))

func _on_menu() -> void:
	STransitions.change_scene_with_transition(C.SCREENS.MENU)
