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

func _on_ButtonLoadGame_pressed():
	var _retval = get_tree().change_scene_to(load_game_scene)

func _on_ButtonNewGame_pressed():
	var _retval = get_tree().change_scene_to(new_game_scene)

func _on_ButtonOptions_pressed():
	TmpVars.put("back_scene", get_tree().get_current_scene().get_filename())
	var _retval = get_tree().change_scene_to(options_scene)

func _on_ButtonQuit_pressed():
	get_tree().quit()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
