class_name CenterPivotComponent extends Node

var target_node: Control

func _ready() -> void:
	if not target_node: target_node = get_parent()
	
	target_node.resized.connect(_on_target_resized)
	_on_target_resized()

func _on_target_resized() -> void:
	if is_instance_valid(target_node):
		target_node.pivot_offset = target_node.size / 2.0
