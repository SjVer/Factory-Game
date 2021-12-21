extends Node

# exports
export(String, FILE, "*.tscn") var back_scene_path

var savedata: SaveData
var epoch: int

func preload_save(_savedata: SaveData):
	# used to load a savefile before opening the World scene
	savedata = _savedata
	print("loading save %s" % savedata.name)

	$World/Player.position = savedata.player_pos

func _ready():
	$UI/JoyPad.PadStyle = ["Joystick", "D-Pad"][Settings.gamepad_style]
	$UI/JoyPad.visible = Settings.show_gamepad
	$UI/JoyPad._ready()
	# set epoch
	epoch = OS.get_unix_time()

func _physics_process(_delta):
	$UI/Coordinates.text = "(%04d, %04d)" % [$World/Player.position.x, $World/Player.position.y]

# save stuff
func update_total_time():
	var newstamp = OS.get_unix_time()
	var played = (newstamp - epoch) / 60
	print("played: ",played)
	savedata.update_total_played(played)
	epoch = OS.get_unix_time()

func save_world():
	if savedata == null: return
	update_total_time()
	savedata.player_pos = $World/Player.position
	SaveHandler.save(savedata)

# cancelling stuff
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		back()
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		back()
func back():
	# save
	save_world()
	# go to main menu
	var scene: PackedScene = load(back_scene_path)
	var _retval = get_tree().change_scene_to(scene)
