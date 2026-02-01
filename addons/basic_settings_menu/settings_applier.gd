extends Node

func _ready() -> void:
	SettingsManager.profile_changed.connect(apply_all_settings)
	apply_all_settings()

func apply_all_settings() -> void:
	var profile: SettingsProfile = SettingsManager.get_profile()
	if not is_instance_valid(profile): return

	_apply_video_settings(profile.video)
	_apply_audio_settings(profile.audio)
	_apply_gameplay_settings(profile.gameplay)
	_apply_accessibility_settings(profile.accessibility)
	print("All settings applied.")

func apply_single_setting(category: String, setting: String, value) -> void:
	var profile = SettingsManager.get_profile()
	
	match category:
		"video":
			# We pass a temporary, modified dictionary to the apply function
			var temp_settings = profile.video.duplicate()
			temp_settings[setting] = value
			_apply_video_settings(temp_settings)
		"audio":
			var temp_settings = profile.audio.duplicate()
			temp_settings[setting] = value
			_apply_audio_settings(temp_settings)


func _apply_video_settings(settings: Dictionary) -> void:
	var mode = DisplayServer.WINDOW_MODE_FULLSCREEN if settings.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, settings.borderless)
	
	if mode == DisplayServer.WINDOW_MODE_WINDOWED:
		var resolution: Vector2i = settings.resolution
		DisplayServer.window_set_size(resolution)
		var screen_size = DisplayServer.screen_get_size()
		DisplayServer.window_set_position(screen_size / 2 - resolution / 2)

func _apply_audio_settings(settings: Dictionary) -> void:
	for bus_name in settings:
		var bus_index = AudioServer.get_bus_index(bus_name)
		if bus_index != -1:
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(settings[bus_name]))

func _apply_gameplay_settings(settings: Dictionary) -> void:
	Engine.max_fps = settings.max_fps

func _apply_accessibility_settings(settings: Dictionary) -> void:
	TranslationServer.set_locale(settings.current_locale)
