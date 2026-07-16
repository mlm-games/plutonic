extends Node

signal score_changed(new_score: int)
signal high_score_changed(new_high: int)
signal game_over_triggered
signal game_started
signal sun_created

var score: int = 0: set = _set_score
var high_score: int = 0: set = _set_high_score
var is_game_active := false
var pending_load_data: Dictionary = {}
var last_save_timestamp: float = 0.0

func _ready() -> void:
	_load_data()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_CLOSE_REQUEST:
			if is_game_active:
				save_game_state()
		NOTIFICATION_WM_GO_BACK_REQUEST:
			if is_game_active:
				save_game_state()

func _set_score(value: int) -> void:
	score = value
	score_changed.emit(score)
	if score > high_score:
		high_score = score

func _set_high_score(value: int) -> void:
	high_score = value
	high_score_changed.emit(high_score)
	_save_data()

func start_game(load_if_available: bool = false) -> void:
	score = 0
	is_game_active = true
	if load_if_available and has_game_save():
		pending_load_data = _read_game_save()
	else:
		pending_load_data = {}
		clear_game_save()
	game_started.emit()

func end_game() -> void:
	is_game_active = false
	if score > high_score:
		high_score = score
	clear_game_save()
	game_over_triggered.emit()

func add_score(planet_tier: int) -> void:
	if planet_tier >= 0 and planet_tier < C.PLANET_SCORES.size():
		score += C.PLANET_SCORES[planet_tier]

func notify_sun_created() -> void:
	add_score(C.PlanetType.SUN)
	sun_created.emit()

func get_share_text() -> String:
	return "I scored %d points in Plutonic! Can you beat my score? 🪐✨" % score

func has_game_save() -> bool:
	return FileAccess.file_exists(C.GAME_SAVE_FILE)

func clear_game_save() -> void:
	if FileAccess.file_exists(C.GAME_SAVE_FILE):
		DirAccess.remove_absolute(C.GAME_SAVE_FILE)
	pending_load_data = {}

func save_game_state() -> void:
	if not is_game_active or not get_tree() or not get_tree().current_scene is Node2D:
		return
	var scene = get_tree().current_scene
	var shooter = scene.get_node_or_null("%Shooter") as Shooter
	if not shooter:
		return

	var planets_data: Array = []
	for node in get_tree().get_nodes_in_group("planets"):
		if node is Planet:
			var p: Planet = node
			if shooter.current_planet_holder and p.get_parent() == shooter.current_planet_holder:
				continue
			planets_data.append({
				"tier": p.tier,
				"pos_x": p.global_position.x,
				"pos_y": p.global_position.y,
				"vel_x": p.linear_velocity.x,
				"vel_y": p.linear_velocity.y,
				"ang_vel": p.angular_velocity,
				"rot": p.rotation,
				"has_been_shot": p.has_been_shot,
				"has_collided_once": p.has_collided_once,
			})

	var current_tier: int = -1
	if shooter.current_planet:
		current_tier = shooter.current_planet.tier

	var data := {
		"version": C.SAVE_VERSION,
		"score": score,
		"high_score": high_score,
		"next_planet_tier": shooter.next_planet_tier,
		"current_planet_tier": current_tier,
		"planets": planets_data,
		"timestamp": Time.get_unix_time_from_system(),
	}

	var file := FileAccess.open(C.GAME_SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		last_save_timestamp = data.timestamp

func _read_game_save() -> Dictionary:
	if not has_game_save():
		return {}
	var file := FileAccess.open(C.GAME_SAVE_FILE, FileAccess.READ)
	if not file:
		return {}
	var data = JSON.parse_string(file.get_as_text())
	if data is Dictionary and data.get("version", 0) == C.SAVE_VERSION:
		return data
	return {}

func load_game_state_into_scene() -> void:
	if pending_load_data.is_empty():
		return
	score = pending_load_data.get("score", 0)
	pending_load_data = {}

func prepare_continue() -> void:
	if has_game_save():
		pending_load_data = _read_game_save()

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
