extends Node

var sound_volume: float setget sound_volume_set
var music_volume: float setget music_volume_set

func sound_volume_set(value: float) -> void:
    sound_volume = value
    volume_setter("Sound", value)

func music_volume_set(value: float) -> void:
    music_volume = value
    volume_setter("Music", value)

    
func volume_setter(name: String, value: float) -> void:
    var i = AudioServer.get_bus_index(name)
    AudioServer.set_bus_volume_db(i, linear2db(value))
    AudioServer.set_bus_mute(i, value == 0)

func _ready():
    sound_volume_set(Settings.sound)
    music_volume_set(Settings.music)