extends Node

func read_to_savedata(file_path: String) -> SaveData:
	var file = File.new()
	file.open(file_path, File.READ)
	var dict = JSON.parse(file.get_as_text()).result
	file.seek(0)
	return SaveData.new().from_dict(dict)

func get_saves() -> Array:
	# returns an array of dictionaries representing all save files
	var files = []
	var dir = Directory.new()
	dir.open(ProjectSettings.get_setting("filesystem/saving/save_directory"))
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "": break
		elif file.ends_with(".json"): files.append(read_to_savedata(dir.get_current_dir() + '/' + file))
	
	dir.list_dir_end()
	return files

func save(savedata: SaveData):
	if not Directory.new().dir_exists(ProjectSettings.get_setting("filesystem/saving/save_directory")):
		Directory.new().make_dir_recursive(ProjectSettings.get_setting("filesystem/saving/save_directory"))

	var file = File.new()
	var _status = file.open(savedata.path, File.WRITE)
	file.store_string(savedata.to_string())
	file.close()
