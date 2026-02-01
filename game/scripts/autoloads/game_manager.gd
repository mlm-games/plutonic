extends Node

signal score_changed(new_score: int)
signal high_score_changed(new_high: int)
signal game_over_triggered
signal game_started
signal sun_created # Victory!

var score: int = 0: set = _set_score
var high_score: int = 0: set = _set_high_score
var is_game_active := false

func _ready() -> void:
	_load_data()

func _set_score(value: int) -> void:
	score = value
	score_changed.emit(score)
	if score > high_score:
		high_score = score

func _set_high_score(value: int) -> void:
	high_score = value
	high_score_changed.emit(high_score)
	_save_data()

func start_game() -> void:
	score = 0
	is_game_active = true
	game_started.emit()

func end_game() -> void:
	is_game_active = false
	if score > high_score:
		high_score = score
	game_over_triggered.emit()

func add_score(planet_tier: int) -> void:
	if planet_tier >= 0 and planet_tier < C.PLANET_SCORES.size():
		score += C.PLANET_SCORES[planet_tier]

func notify_sun_created() -> void:
	add_score(C.PlanetType.SUN)
	sun_created.emit()

func get_share_text() -> String:
	return "I scored %d points in Plutonic! Can you beat my score? 🪐✨" % score

func _save_data() -> void:
	var data := {"high_score": high_score}
	var file := FileAccess.open(C.SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func _load_data() -> void:
	if FileAccess.file_exists(C.SAVE_FILE):
		var file := FileAccess.open(C.SAVE_FILE, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if data is Dictionary:
				high_score = data.get("high_score", 0)
