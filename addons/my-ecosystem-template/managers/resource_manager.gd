class_name ResourceManager extends Node

## Use a func _update_collection_in_editor() function to scan and use the files


## Only for .tres files
static func get_resource_paths_in_directory(resources_dir: String, load_resource_paths: bool = false) -> Dictionary[StringName, Variant]:
	var dir : DirAccess = DirAccess.open(resources_dir)
	var res_list : Dictionary[StringName, Variant] = {}
	if load_resource_paths:
		for res:String in dir.get_files():
			if res.ends_with(".tres"):
				if load_resource_paths:
					var loaded_res : Resource = load(resources_dir + res)
					loaded_res.resource_name = res.trim_suffix(".tres")
					res_list.get_or_add(loaded_res.resource_name, loaded_res)
				else:
					res_list.get_or_add(res.trim_suffix(".tres"), resources_dir + res)
	return res_list

## All (even .gd) files
static func _scan_directory_recursive(path: String, extension: String) -> Array:
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = path + "/" + file_name
			if dir.current_is_dir() and not file_name.begins_with("."):
				files.append_array(_scan_directory_recursive(full_path, extension))
			elif file_name.ends_with("." + extension):
				files.append(full_path)
			file_name = dir.get_next()
	return files

static func get_resource_name(res: Resource) -> StringName:
	if res.resource_name != "":
		return res.resource_name
	
	var res_name = res.resource_path.trim_suffix(".tres").split("/")[-1].trim_prefix("*/")
	
	if res_name != "":
		return res_name
	else:
		push_error("Res path or name not present for resource")
		return "temp"
