extends Node

func preload_save(savedata: SaveData):
	# used to load a savefile before opening the World scene
	print("loading save %s" % savedata.name)
	
	var chunk = savedata.get_chunk(0,0)
	for x in range(ProjectSettings.get_setting("world/chunk/size")):
		for y in range(ProjectSettings.get_setting("world/chunk/size")):
			$TileMap.set_cell(x, y, chunk.get_slot(x, y))

