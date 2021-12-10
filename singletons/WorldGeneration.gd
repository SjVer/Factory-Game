extends Node

# script to handle world generation related stuff

func generate_new_world(world_name: String, world_seed: int) -> File:
	var filename = ProjectSettings.get_setting("filesystem/saving/save_directory") + "/%s.json" % world_name
	
	var dict: Dictionary = {}
	dict["version"] = ProjectSettings.get_setting("application/config/version")
	dict["path"] = filename
	dict["name"] = world_name
	dict["seed"] = world_seed
	dict["last_played"] = OS.get_unix_time()
	dict["total_played"] = 0

	# ========= generation =========
	#
	#
	
	# ========= save to file =========
	
	if not Directory.new().dir_exists(ProjectSettings.get_setting("filesystem/saving/save_directory")):
		Directory.new().make_dir_recursive(ProjectSettings.get_setting("filesystem/saving/save_directory"))

	var worldfile = File.new()
	var _status = worldfile.open(filename, File.WRITE)
	worldfile.store_string(JSON.print(dict, "\t"))
	# worldfile.close()
	
	return worldfile
