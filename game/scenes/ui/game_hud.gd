extends Control

@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var next_preview: TextureRect = %NextPreview
@onready var next_label: Label = %NextLabel

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

func _update_preview(preview: TextureRect, label: Label, tier: int) -> void:
	tier = clampi(tier, 0, C.PLANET_TEXTURES.size() - 1)
	var texture_path := C.PLANET_TEXTURES[tier]
	var texture := load(texture_path) as Texture2D
	if texture:
		preview.texture = texture
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preview.custom_minimum_size = Vector2(70, 70)
	label.text = C.PLANET_NAMES[tier]
	label.visible = true
