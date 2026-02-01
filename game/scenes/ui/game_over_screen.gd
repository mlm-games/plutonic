extends Control

@onready var final_score_label: Label = %FinalScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var new_best_label: Label = %NewBestLabel
@onready var restart_button: Button = %RestartButton
@onready var share_button: Button = %ShareButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	final_score_label.text = tr("GAME_OBJECTIVE_HIGH_SCORE") + ": %d" % GameManager.score
	high_score_label.text = tr("GAME_OBJECTIVE_HIGH_SCORE") + ": %d" % GameManager.high_score
	new_best_label.visible = GameManager.score >= GameManager.high_score and GameManager.score > 0
	
	restart_button.pressed.connect(_on_restart)
	share_button.pressed.connect(_on_share)
	menu_button.pressed.connect(_on_menu)
	
	restart_button.grab_focus()

func _on_restart() -> void:
	get_tree().reload_current_scene()

func _on_share() -> void:
	var text := GameManager.get_share_text()
	
	# For web, use JavaScript interface
	if OS.has_feature("web"):
		JavaScriptBridge.eval("navigator.clipboard.writeText('%s')" % text)
		# Or open share dialog if available
	else:
		DisplayServer.clipboard_set(text)
	
	# Show feedback
	share_button.text = "Copied!"
	get_tree().create_timer(1.5).timeout.connect(func(): share_button.text = "Share")

func _on_menu() -> void:
	STransitions.change_scene_with_transition(C.SCREENS.MENU)
