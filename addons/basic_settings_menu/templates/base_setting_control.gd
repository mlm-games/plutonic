@tool
class_name BaseSettingControl extends HBoxContainer

signal confirmation_requested(old_value, new_value)

@onready var interactive_element: Control = $InteractablePartOfSetting
@onready var _label: Label = $Label

var _category: String
var _setting_name: String
var _sfx_player: AudioStreamPlayer
var _requires_confirmation := false
var _menu_controller: SettingsMenu



func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.stream = preload("res://addons/basic_settings_menu/settings-test-sound.ogg")
	_sfx_player.bus = &"Sfx"
	add_child(_sfx_player)

	interactive_element.focus_entered.connect(func(): _sfx_player.play())
	mouse_entered.connect(interactive_element.grab_focus)

func _on_focus_entered() -> void:
	if is_instance_valid(_menu_controller) and _menu_controller.can_play_focus_sfx:
		_sfx_player.play()

func initialize(p_menu_controller: SettingsMenu, category: String, setting_name: String, options: Dictionary = {}) -> void:
	_menu_controller = p_menu_controller
	_category = category
	_setting_name = setting_name
	_label.text = setting_name.capitalize().replace("_", " ")

	var current_value = SettingsManager.get_setting(_category, _setting_name)

	match interactive_element:
		interactive_element when interactive_element is CheckButton:
			interactive_element.button_pressed = current_value
			interactive_element.toggled.connect(_on_value_changed)
		interactive_element when interactive_element is HSlider:
			interactive_element.value = current_value
			interactive_element.value_changed.connect(_on_value_changed)
			interactive_element.value_changed.connect(func(_v): _sfx_player.play())
		interactive_element when interactive_element is SpinBox:
			interactive_element.value = current_value
			interactive_element.value_changed.connect(_on_value_changed)
		interactive_element when interactive_element is OptionButton:
			var index_to_select = -1
			for i in options.size():
				var key = options.keys()[i]
				var text = options[key]
				interactive_element.add_item(text)
				interactive_element.set_item_metadata(i, key)
				if key == current_value:
					index_to_select = i
			
			if index_to_select != -1:
				interactive_element.select(index_to_select)
			
			interactive_element.item_selected.connect(_on_option_item_selected)

func _on_option_item_selected(index: int) -> void:
	var new_value = interactive_element.get_item_metadata(index)
	
	if _requires_confirmation:
		var old_value = SettingsManager.get_setting(_category, _setting_name)
		if old_value != new_value:
			confirmation_requested.emit(old_value, new_value)
	else:
		_on_value_changed(new_value)


func _on_value_changed(new_value) -> void:
	SettingsManager.set_setting(_category, _setting_name, new_value)

func revert_ui_to_value(value_to_revert_to) -> void:
	if interactive_element is OptionButton:
		for i in interactive_element.item_count:
			if interactive_element.get_item_metadata(i) == value_to_revert_to:
				interactive_element.select(i)
				return
