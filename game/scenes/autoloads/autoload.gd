## Should be set as the autoload by default, can call (global) creation and add_child to this instead of getting the scene tree everytime.
extends Node #class_name A for Autoload

static var tree : SceneTree = Engine.get_main_loop()

func  _ready() -> void:
			print(ProjectSettings.get_global_class_list())
			print(ProjectSettings.get_global_class_list())
