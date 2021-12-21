extends Node

func generate_chunk(_seed: int, x: int, y: int) -> Chunk:
	return Chunk.new()

func generate_new_world(world_name: String, world_seed: int) -> SaveData:
	var filename = ProjectSettings.get_setting("filesystem/saving/save_directory") + "/%s.json" % world_name

	var savedata: SaveData = SaveData.new()
	savedata.version = ProjectSettings.get_setting("application/config/version")
	savedata.path = filename
	savedata.name = world_name
	savedata.world_seed = world_seed
	savedata.last_played = OS.get_unix_time()
	savedata.total_played = 0
	assert(savedata.is_valid(), "Generated savefile %s is invalid!" % world_name)

	# ========= generation =========
	
	var first_chunk = generate_chunk(savedata.world_seed, 0, 0)
	savedata.set_chunk(0, 0, first_chunk)
	
	# ========= save to file =========
	
	return savedata
