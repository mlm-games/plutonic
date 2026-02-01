class_name SettingsProfile extends Resource

#@export_group("Accessibility")
@export var accessibility: Dictionary = {
	"current_locale": "en",
}
#@export_group("Gameplay")
@export var gameplay: Dictionary = {
	"max_fps": 60,
}
#@export_group("Video")
@export var video: Dictionary = {
	"fullscreen": true,
	"borderless": false,
	"resolution": Vector2i(1920, 1080),
}
#@export_group("Audio")
@export var audio: Dictionary = {
	"Master": 0.8,
	"Music": 0.8,
	"Sfx": 0.8,
}
