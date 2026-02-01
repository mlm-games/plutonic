#class_name UndoRedoManager
extends Node

signal history_changed

var undo_redo: UndoRedo = UndoRedo.new()

func _ready():
	undo_redo.version_changed.connect(history_changed.emit)

func do_undo():
	if undo_redo.has_undo():
		undo_redo.undo()

func do_redo():
	if undo_redo.has_redo():
		undo_redo.redo()

func _unhandled_key_input(event: InputEvent):
	if event.is_action_pressed("undo"):
		do_undo()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("redo"):
		do_redo()
		get_viewport().set_input_as_handled()
