# Purpose: This autoload is the SINGLE SOURCE OF TRUTH for settings data.
# Its job is to load, save, provide access to, and merge settings with defaults.
# It does NOT apply settings.

extends Node

# This signal is emitted whenever settings are loaded or changed,
# telling other systems (like SettingsApplier) to update.
signal profile_changed

var _active_profile: SettingsProfile

const SETTINGS_SAVE_PATH: String = "user://settings_profile.tres"

func _ready() -> void:
	_load_and_reconcile_profile()


# Public API

func get_profile() -> SettingsProfile:
	return _active_profile

func get_setting(category: String, setting: String, default = null):
	var cat_dict: Dictionary = _active_profile.get(category)
	if cat_dict.has(setting):
		return cat_dict.get(setting)

	var default_res = SettingsProfile.new()
	if default_res.has(category):
		return default_res.get(category).get(setting, default)
	

func set_setting(category: String, setting: String, value) -> void:
	var cat_dict: Dictionary = _active_profile.get(category)
	cat_dict[setting] = value
	# Don't save immediately. Personal preference / The user might change more things and would not want to save them.
	# The "Save" button in the UI will call save_profile().


# Load/Save Logic

func _load_and_reconcile_profile() -> void:
	var default_profile = SettingsProfile.new()
	
	if FileAccess.file_exists(SETTINGS_SAVE_PATH):
		var loaded_profile = ResourceLoader.load(SETTINGS_SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
		if loaded_profile is SettingsProfile:
			_active_profile = _reconcile(default_profile, loaded_profile)
		else:
			push_warning("Settings file is corrupt. Loading defaults.")
			_active_profile = default_profile
	else:
		_active_profile = default_profile
	
	save_profile() # Save immediately to ensure new default values are written to disk.
	profile_changed.emit()
	
## Ensures that if new settings are added to the default profile,
## they are merged into the user's loaded profile.
func _reconcile(default: SettingsProfile, user: SettingsProfile) -> SettingsProfile:
	var reconciled_profile = user.duplicate() # Start with the user's saved data
	
	for category_dict_info in default.get_script().get_script_property_list():
		var category_name = category_dict_info.name
		if category_name == "settings_profile.gd": continue #Needed to skip
		var default_settings: Dictionary = default.get(category_name)
		var user_settings: Dictionary = reconciled_profile.get(category_name)
		
		for setting_key in default_settings:
			if not user_settings.has(setting_key):
				# The user's save file is missing this setting. Add it from the defaults.
				user_settings[setting_key] = default_settings[setting_key]
				
	return reconciled_profile

func save_profile() -> void:
	if not _active_profile:
		push_error("Cannot save, no settings resource loaded.")
		return
	
	# ResourceSaver handles serialization of all Godot types correctly.
	var error = ResourceSaver.save(_active_profile, SETTINGS_SAVE_PATH)
	if error == OK:
		print("Settings saved to: " + SETTINGS_SAVE_PATH)
		profile_changed.emit() # Signal that settings were saved and should be applied.
	else:
		push_error("Failed to save settings. Error code: " + str(error))
