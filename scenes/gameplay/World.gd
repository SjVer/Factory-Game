extends Node

func preload_save(save: SaveData):
	# used to load a savefile before opening the World scene
	print("loading save %s" % save.name)
	print(save.chunks)

func _process(delta):
	print("process")