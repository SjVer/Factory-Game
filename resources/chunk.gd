extends Resource
class_name Chunk

var slots: Array
var size = ProjectSettings.get_setting("world/chunk/size")

func _init():
    slots = []; slots.resize(size * size)

func from_dict(dict: Dictionary) -> Chunk:
    _init()
    slots = dict["slots"]
    return self

func to_dict() -> Dictionary:
    return {"slots": slots}

func set_slot(x: int, y: int, cell: int):
    slots[x * size + y] = cell

func get_slot(x: int, y: int):
    return slots[x * size + y]