extends Control

@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var next_preview: Sprite2D = %NextPreview
@onready var next_label: Label = %NextLabel


const PLANET_TEXTURES: Array[String] = [
	"res://game/assets/svg/planets/pluto.svg",
	"res://game/assets/svg/planets/moon.svg",
	"res://game/assets/svg/planets/mercury.svg",
	"res://game/assets/svg/planets/mars.svg",
	"res://game/assets/svg/planets/venus.svg",
	"res://game/assets/svg/planets/earth.svg",
	"res://game/assets/svg/planets/neptune.svg",
	"res://game/assets/svg/planets/uranus.svg",
	"res://game/assets/svg/planets/saturn.svg",
	"res://game/assets/svg/planets/jupiter.svg",
	"res://game/assets/svg/planets/sun.svg",
]

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.high_score_changed.connect(_on_high_score_changed)
	
	_on_score_changed(GameManager.score)
	_on_high_score_changed(GameManager.high_score)

func _on_score_changed(new_score: int) -> void:
	score_label.text = tr("GAME_OBJECTIVE_SCORE")  + ": %d" % new_score

func _on_high_score_changed(new_high: int) -> void:
	high_score_label.text = tr("GAME_OBJECTIVE_HIGH_SCORE") + ": %d" % new_high

func update_next_preview(tier: int) -> void:
	_update_preview(next_preview, next_label, tier)

func _update_preview(preview: Sprite2D, label: Label, tier: int) -> void:
	var texture_path := PLANET_TEXTURES[tier]
	var texture := load(texture_path) as Texture2D
	if texture:
		preview.texture = texture
		# Scale to fit preview area (max 30px radius = 60px diameter)
		# SVGs are 200px wide, so scale = 60/200 = 0.3
		# For Saturn, adjust width for the wider SVG
		if tier == C.PlanetType.SATURN:
			preview.scale = Vector2(0.42, 0.3)  # (280/200) * 0.3 for width
		else:
			preview.scale = Vector2(0.3, 0.3)
	label.text = C.PLANET_NAMES[tier]
