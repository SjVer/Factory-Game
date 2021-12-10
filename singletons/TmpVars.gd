extends Node

onready var vars: Dictionary = {}

func clear() -> void:
    vars.clear()

func put(name: String, value) -> void:
    vars[name] = value

func take(name: String):
    var value = vars.get(name)
    vars.erase(name)
    return value

func has(name: String) -> bool:
    return vars.has(name)