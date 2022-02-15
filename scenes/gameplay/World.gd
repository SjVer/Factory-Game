extends Node2D

# exports
export(String, FILE, "*.tscn") var back_scene_path

var savedata: SaveData
var epoch: int
onready var TouchHandler = preload("res://scenes/gameplay/TouchHandler.gd").new()
var EntityManager = load("res://entities/EntityManager.cs").new()

func preload_save(_savedata: SaveData):
	# used to load a savefile before opening the World scene
	savedata = _savedata
	print("loading save %s" % savedata.name)

	$World/Player.position = savedata.player_pos

func _ready():
	# set up touch handler
	TouchHandler.tilemap = $World/Ground
	TouchHandler.connect("_tile_set_request", self, "_on_tile_set_request")
	add_child(TouchHandler)
	move_child(TouchHandler, 0)

	$UI/JoyPad.PadStyle = ["Joystick", "D-Pad"][Settings.gamepad_style]
	$UI/JoyPad.visible = Settings.show_gamepad
	$UI/JoyPad._ready()

	# set epoch
	epoch = OS.get_unix_time()

	# some temporary terrain
	for x in range(ProjectSettings.get_setting("world/chunk/size")):
		for y in range(ProjectSettings.get_setting("world/chunk/size")):
			$World/Ground.set_cell(x, y, 0)
	
func _physics_process(_delta):
	$UI/Coordinates.text = "(%04d, %04d)" % [$World/Player.position.x, $World/Player.position.y]

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		back()

# process stuff
func _on_tile_set_request(position: Vector2, clear: bool):
	if clear:
		EntityManager.RemoveEntity(position).Delete()

	elif not EntityManager.EntityAt(position):
		var belt = EntityManager.CreateNewEntity("Entity", {})

		var rect = RectangleShape2D.new()
		rect.extents = Vector2(16, 14)
		
		belt.ConfigAnimatedEntity("res://assets/sprites/entities/belt-1/belt-1-rf.png", [2, 2], 2, true)
		belt.Init($World/Ground)
		belt.Coordinates = position
		
		$World/Entities/Layer1.add_child(belt)
		EntityManager.SetEntity(belt, position)

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
func back():
	# save
	save_world()
	# go to main menu
	var scene: PackedScene = load(back_scene_path)
	var _retval = get_tree().change_scene_to(scene)
