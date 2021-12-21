extends Resource
class_name SaveData

var version: String = ProjectSettings.get_setting("application/config/version")
var path: String
var name: String
var world_seed: int
var last_played: int
var total_played: int

var player_pos: Vector2
var chunks: Dictionary = {}

func _init():
	chunks = {}

func from_dict(dict: Dictionary) -> SaveData:
	_init()
	version = dict["version"]
	path = dict["path"]
	name = dict["name"]
	world_seed = dict["seed"]
	last_played = dict["last_played"]
	total_played = dict["total_played"]

	player_pos = Vector2(str2var("Vector2" + dict["player_pos"]))
	chunks = {}

	# load chunks
	for coord in dict["chunks"]:
		var key = Vector2(str2var("Vector2" + coord))
		chunks[key] = Chunk.new().from_dict(dict["chunks"][coord])

	return self

func is_valid() -> bool:
	# check to see if the current state is valid
	return true

func to_string() -> String:
	# make into string
	var dict = {
		"version": version,
		"path": path,
		"name": name,
		"seed": world_seed,
		"last_played": last_played,
		"total_played": total_played,
		"player_pos": player_pos,
		"chunks": {}
	}
	# save chunks
	for coord in chunks:
		dict["chunks"][coord] = chunks[coord].to_dict()

	return JSON.print(dict, "\t")

func update_total_played(mins: int):
	total_played += int(mins)

func set_chunk(x: int, y: int, chunk: Chunk):
	# sets a chunk
	chunks[Vector2(x, y)] = chunk

func get_chunk(x: int, y: int) -> Chunk:
	# gets a chunk WITHOUT CHECKING IF IT EXISTS
	return chunks[Vector2(x, y)]

func has_chunk(x: int, y: int) -> bool:
	# checks if a chunk exists
	return chunks.has(Vector2(x, y))
