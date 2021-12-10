extends Node

func read_to_dict(file_path: String) -> Dictionary:
	var file = File.new()
	file.open(file_path, File.READ)
	var dict = JSON.parse(file.get_as_text()).result
	file.seek(0)
	return dict

func get_saves() -> Array:
	# returns an array of dictionaries representing all save files
	var files = []
	var dir = Directory.new()
	dir.open(ProjectSettings.get_setting("filesystem/saving/save_directory"))
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "": break
		elif file.ends_with(".json"): files.append(read_to_dict(dir.get_current_dir() + '/' + file))
	
	dir.list_dir_end()
	return files
