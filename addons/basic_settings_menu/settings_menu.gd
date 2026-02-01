#TODO: ADD ICONS SAYING ESC FOR BACK, ENTER FOR SELECT (or maybe just use the controller icons addon)
#TODO: ADD pause_on_alt_tab
#TODO: VolumeSliders makes sound when changed indicating the sound change (not the awful sound, maybe something better like until then's)
#const BUS_MASTER = "Master"
#const BUS_MUSIC = "Music"
#const BUS_SFX = "SFX"

# Purpose: This script only manages the UI scene.
# It dynamically builds the UI from setting templates based on the data
# in SettingsData, and connects their signals.

class_name SettingsMenu extends Control

# References to the templates used to build the UI
const BOOL_CONTAINER = preload("res://addons/basic_settings_menu/templates/boolean_container.tscn")
const OPTION_CONTAINER = preload("res://addons/basic_settings_menu/templates/option_container.tscn")
const SLIDER_CONTAINER = preload("res://addons/basic_settings_menu/templates/slider_setting_container.tscn")
const INT_CONTAINER = preload("res://addons/basic_settings_menu/templates/int_container.tscn")

const TYPE_TO_TEMPLATE_MAP: Dictionary = {
	TYPE_BOOL: BOOL_CONTAINER,
	TYPE_INT: INT_CONTAINER,
	TYPE_FLOAT: INT_CONTAINER,
}

@onready var _tabs: Dictionary = {
	"accessibility": %Accessibility,
	"gameplay": %Gameplay,
	"video": %Video,
	"audio": %Audio,
}

@onready var confirmation_dialog: ConfirmationDialog = %ConfirmationDialog
@onready var page_animator: PopupAnimator = %PopupAnimator

var _pending_confirmation_control: BaseSettingControl
var _pending_old_value

var can_play_focus_sfx := false

func _ready() -> void:
	confirmation_dialog.confirmed.connect(_on_dialog_confirmed)
	confirmation_dialog.canceled.connect(_on_dialog_dismissed)
	
	_build_ui_from_settings_profile()
	
	visible = false
	page_animator.animate_in()
	
	# To prevent the initial focus button sound
	A.tree.create_timer(0.1, false).timeout.connect(func(): can_play_focus_sfx = true)
	
	# Adding a new setting in GameSettingsSave.gd,
	# will make it appear here automatically if a rule is added to the functions below.

func _build_ui_from_settings_profile() -> void:
	var profile: SettingsProfile = SettingsManager.get_profile()
	
	# Iterate over categories defined in the profile (e.g., "video", "audio")
	for category_name in profile.get_script().get_script_property_list():
		var category_key = category_name.name
		if not _tabs.has(category_key): continue

		var parent_container: VBoxContainer = _tabs[category_key]
		var settings_in_category: Dictionary = profile.get(category_key)

		# Iterate over settings within that category (e.g., "fullscreen", "resolution")
		for setting_key in settings_in_category:
			var setting_value = settings_in_category[setting_key]
			_create_setting_control(parent_container, category_key, setting_key, setting_value)

func _create_setting_control(parent: Container, category: String, setting_name: String, value, options: Dictionary = {}, requires_conf := false) -> void:
	var template: PackedScene

	# Determine which template and options to use based on setting name or type
	match setting_name:
		"resolution":
			template = OPTION_CONTAINER
			for res in SettingsConstants.RESOLUTIONS_ARRAY:
				options[res] = "%d x %d" % [res.x, res.y]
				requires_conf = true
			
		"current_locale":
			template = OPTION_CONTAINER
			options = SettingsConstants.LOCALES
		
		setting_name when setting_name in ["Master", "Music", "Sfx"]:
			template = SLIDER_CONTAINER
		_:
			# Default to a template based on the value's data type
			template = TYPE_TO_TEMPLATE_MAP.get(typeof(value))

	if not template:
		push_warning("No template found for setting '%s' in category '%s'" % [setting_name, category])
		return

	var container: BaseSettingControl = template.instantiate()
	
	container._requires_confirmation = requires_conf
	
	if requires_conf:
		container.confirmation_requested.connect(_on_confirmation_requested.bind(container))
	
	container.initialize.call_deferred(self, category, setting_name, options)
	parent.add_child(container)

func _on_confirmation_requested(old_value, new_value, control: BaseSettingControl) -> void:
	_pending_confirmation_control = control
	_pending_old_value = old_value

	# 1. Temporarily APPLY the new setting for preview
	SettingsApplier.apply_single_setting(control._category, control._setting_name, new_value)
	
	# 2. Start the dialog
	var msg = "Keep these display settings?\nReverting in %d seconds."
	confirmation_dialog.start(msg, 10.0)

func _on_dialog_confirmed() -> void:
	if not _pending_confirmation_control: return
	
	# 1. The user confirmed. Officially set the value in the data model.
	var control = _pending_confirmation_control
	var new_value = control.interactive_element.get_item_metadata(control.interactive_element.selected)
	SettingsManager.set_setting(control._category, control._setting_name, new_value)
	
	# 2. Clear the pending state
	_pending_confirmation_control = null
	_pending_old_value = null

func _on_dialog_dismissed() -> void:
	if not _pending_confirmation_control: return
	
	# 1. User canceled or timer ran out. Revert the setting.
	var control = _pending_confirmation_control
	SettingsApplier.apply_single_setting(control._category, control._setting_name, _pending_old_value)
	
	# 2. Revert the UI control to show the old value.
	control.revert_ui_to_value(_pending_old_value)

	# 3. Clear the pending state
	_pending_confirmation_control = null
	_pending_old_value = null

func _on_save_button_pressed() -> void:
	SettingsManager.save_profile()
	# The 'settings_changed' signal in SettingsManager will trigger SettingsApplier.
	page_animator.animate_out(queue_free)

func _on_back_button_pressed() -> void:
	# This should transition back to your main menu or previous scene
	# For now, it just hides the settings screen.
	page_animator.animate_out(queue_free)
