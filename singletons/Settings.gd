extends Node

# vars
onready var savefile: File = File.new()

# options
var gamepad_style: int
var show_gamepad: bool
var music: float
var sound: float
var zoom: float

# functions
func _ready(): self.load()
func _exit_tree(): self.save()

func to_dict() -> Dictionary:
	# generate dict from settings
	var dict: Dictionary = {}
	dict["version"] = ProjectSettings.get_setting("application/config/version")

	dict["gamepad_style"] = gamepad_style
	dict["show_gamepad"] = show_gamepad
	dict["sound"] = sound
	dict["music"] = music
	dict["zoom"] = zoom

	return dict

func save():
	# save settings
	var _status = savefile.open(ProjectSettings.get_setting("filesystem/saving/settings_path"), File.WRITE)
	savefile.store_string(JSON.print(to_dict(), "\t"))
	savefile.close()

func load():
	# load settings
	var defaulted = false
	var _status = savefile.open(ProjectSettings.get_setting("filesystem/saving/settings_path"), File.READ)
	var dict = JSON.parse(savefile.get_as_text()).result
	savefile.close()

	if _status != OK or dict["version"] != ProjectSettings.get_setting("application/config/version"):
		# settings version isn't the newest, set to default
		defaulted = true
		var defaultfile = File.new()
		defaultfile.open("res://assets/data/default_settings.json", File.READ)
		dict = JSON.parse(defaultfile.get_as_text()).result
		defaultfile.close()

	# set options
	gamepad_style = dict["gamepad_style"]
	show_gamepad = dict["show_gamepad"]
	sound = dict["sound"]
	music = dict["music"]
	zoom = dict["zoom"]

	print("Settings loaded" if not defaulted else "Settings outdated or corrupted. Loaded default settings")
