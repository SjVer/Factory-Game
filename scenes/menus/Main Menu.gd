extends MarginContainer

# exports
export(PackedScene) var load_game_scene
export(PackedScene) var new_game_scene
export(PackedScene) var options_scene

# buttons
onready var button_load_game: Button = $VBoxContainer/ButtonLoadGame
onready var button_new_game	: Button = $VBoxContainer/ButtonNewGame
onready var button_options	: Button = $VBoxContainer/ButtonOptions
onready var button_quit		: Button = $VBoxContainer/ButtonQuit


func _on_ButtonQuit_pressed():
	Debug.print("Quit button pressed")
	get_tree().quit()


func _on_ButtonOptions_pressed():
	Debug.print("Options button pressed")
	var _retval = get_tree().change_scene_to(options_scene)
