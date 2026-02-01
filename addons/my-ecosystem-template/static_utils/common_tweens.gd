class_name CommonTweens extends Node

static func _animate_title_entrance(title_label: CanvasItem) -> void:
	title_label.modulate.a = 0.0
	title_label.position.y -= 50
	#TODO: Use the engulfers animate from offscreen's with a parallel modulate instead...
	var title_tween := title_label.create_tween()
	title_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	title_tween.parallel().tween_property(title_label, "modulate:a", 1.0, 0.8)
	title_tween.parallel().tween_property(title_label, "position:y", title_label.position.y + 50, 0.8)
