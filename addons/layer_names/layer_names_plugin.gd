@tool
extends EditorPlugin

const OUTPUT_FILE := "res://addons/layer_names/generated/layer_names.gd"
const SINGLETON_NAME := "LayerNames"
const SETTING_KEY_FORMAT := "layer_names/%s/layer_%s"
const RENDER_LAYER_COUNT := 20
const PHYSICS_LAYER_COUNT := 32
const NAVIGATION_LAYER_COUNT := 32
const AVOIDANCE_LAYER_COUNT := 32
const INPUT_WAIT_SECONDS := 1.5
const VALID_IDENTIFIER_PATTERN := "[^a-z,A-Z,0-9,_,\\s]"
const BIT_SHIFT_OFFSET := 1

var previous_text := ""
var wait_tickets := 0
var layer_settings_cache := {}

func _enter_tree() -> void:
	print("LayerNames plugin activated.")
	ProjectSettings.settings_changed.connect(_update_layer_names)
	if not FileAccess.file_exists(OUTPUT_FILE):
		_update_layer_names()

func _exit_tree() -> void:
	ProjectSettings.settings_changed.disconnect(_update_layer_names)
	remove_autoload_singleton(SINGLETON_NAME)
	layer_settings_cache.clear()

func _update_layer_names() -> void:
	wait_tickets += 1
	var wait_number := wait_tickets
	await get_tree().create_timer(INPUT_WAIT_SECONDS).timeout
	if wait_number != wait_tickets: return
	
	layer_settings_cache.clear()
	
	var current_text = "".join([
		"extends Node\n\n",
		_create_enum_string("2d_render", RENDER_LAYER_COUNT),
		_create_enum_string("2d_physics", PHYSICS_LAYER_COUNT),
		_create_enum_string("2d_navigation", NAVIGATION_LAYER_COUNT),
		_create_enum_string("3d_render", RENDER_LAYER_COUNT),
		_create_enum_string("3d_physics", PHYSICS_LAYER_COUNT),
		_create_enum_string("3d_navigation", NAVIGATION_LAYER_COUNT),
		_create_enum_string("avoidance", AVOIDANCE_LAYER_COUNT)
	])

	if current_text == previous_text:
		return

	print("Regenerating LayerNames enums")
	_write_to_file(current_text)
	add_autoload_singleton(SINGLETON_NAME, OUTPUT_FILE)

func _write_to_file(content: String) -> void:
	var file := FileAccess.open(OUTPUT_FILE, FileAccess.WRITE)
	file.store_string(content)
	file.close()
	previous_text = content

func _create_enum_string(layer_type: String, max_layer_count: int) -> String:
	var enum_name := _get_enum_name(layer_type)
	var enum_text := ["enum ", enum_name, " {\n\tNONE_NUM = 0,\n\tNONE_BIT = 0,\n"]
	
	for index in max_layer_count:
		var layer_number := index + 1
		var layer_name := _get_layer_name(layer_type, layer_number)
		enum_text.push_back(_generate_enum_entry(layer_number, layer_name))
	
	enum_text.push_back("}\n\n")
	return "".join(enum_text)

func _get_enum_name(layer_type: String) -> String:
	var parts := layer_type.split("_")
	parts.reverse()
	return _sanitise(" ".join(parts))

func _get_layer_name(layer_type: String, layer_number: int) -> String:
	var cache_key := "%s_%s" % [layer_type, layer_number]
	if not layer_settings_cache.has(cache_key): # Performance benifit?
		layer_settings_cache[cache_key] = ProjectSettings.get_setting(
			SETTING_KEY_FORMAT % [layer_type, layer_number]
		)
	return layer_settings_cache[cache_key]

func _generate_enum_entry(layer_number: int, layer_name: String) -> String:
	var key := _sanitise(layer_name)
	if not key:
		key = "LAYER_%s" % layer_number
		
	return "\t%s_NUM = %s,\n\t%s_BIT = %s,\n" % [
		key,
		layer_number,
		key,
		1 << (layer_number - BIT_SHIFT_OFFSET)
	]

func _sanitise(input: String) -> String:
	var regex := RegEx.new()
	regex.compile(VALID_IDENTIFIER_PATTERN)

	var output := regex.sub(input, "", true)
	output = output.to_snake_case().to_upper()

	return output if output.is_valid_identifier() else ""
