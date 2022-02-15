extends MarginContainer

# exports
export(String, FILE, "*.tscn") var back_scene_path
export(int) var seed_length = 10

# inputs
onready var input_name: LineEdit = $Panel/Options/L/Name/LineEdit
onready var input_seed: LineEdit = $Panel/Options/R/Seed/LineEdit
onready var old_seed_text = ""

func _ready():
	# generate random seed
	randomize()
	input_seed.clear()
	for _i in range(seed_length):
		input_seed.text += str(randi() % 10 + 1)
	# set max length
	input_seed.max_length = seed_length
	
func _on_ButtonCreate_pressed():
	# check if save with given name already exists
	for file in SaveHandler.get_saves():
		if file["name"] == input_name.text:
			$PopupAlreadyExists.normal_popup()
			while $PopupAlreadyExists.state == $PopupAlreadyExists.popupState.PENDING: yield(get_tree(), "idle_frame")
			if $PopupAlreadyExists.state == $PopupAlreadyExists.popupState.CANCELLED: return

	print("Creating world named '%s' with seed %d" % [input_name.text, int(input_seed.text)])
	var savedata: SaveData = WorldGeneration.generate_new_world(input_name.text, int(input_seed.text))
	
	# find center of first chunk
	var worldScene: Node = load("res://scenes/gameplay/World.tscn").instance()
	var chunksize = ProjectSettings.get_setting("world/chunk/size")
	var tilemap = worldScene.get_node("World/Ground")
	# savedata.player_pos = Vector2(
	# 	chunksize * tilemap.cell_size.x * tilemap.scale.x / 2,
	# 	chunksize * tilemap.cell_size.y * tilemap.scale.y / 2
	# )
	savedata.player_pos = tilemap.cell_size * tilemap.scale * chunksize / 2

	SaveHandler.save(savedata)
	print("Saved to %s" % savedata.path)

	# load the World scene and make it load the selected save file
	worldScene.preload_save(savedata)
	var root = get_tree().get_root()
	root.get_child(root.get_child_count() - 1).queue_free()
	root.add_child(worldScene)
	get_tree().set_current_scene(worldScene)
		
func _on_Seed_changed(new_text):
	# validate seed (only numbers)
	if new_text.is_valid_integer():
		old_seed_text = new_text
	else:
		input_seed.text = old_seed_text
		input_seed.set_cursor_position(input_seed.text.length())

func _on_Seed_entered(_new_text):
	while input_seed.text.length() < seed_length:
		input_seed.text += '0'

func _on_Reset_pressed():
	# generate random seed
	input_seed.clear()
	for _i in range(seed_length):
		input_seed.text += str(randi() % 10 + 1)

# cancelling stuff
func _on_ButtonCancel_pressed():
	back()
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		back()
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		back()
func back():
	# go to main menu
	var scene: PackedScene = load(back_scene_path)
	var _retval = get_tree().change_scene_to(scene)
