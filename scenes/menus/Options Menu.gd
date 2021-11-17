extends MarginContainer

# exports
export(String, FILE, "*.tscn") var back_scene_path

# buttons
onready var check_option_1	: CheckBox 	= $Panel/Options/CheckBox1
onready var check_option_2	: CheckBox 	= $Panel/Options/CheckBox2
onready var check_option_3	: CheckBox 	= $Panel/Options/CheckBox3
onready var check_option_4	: CheckBox 	= $Panel/Options/CheckBox4
onready var button_back		: Button 	= $Panel/ButtonBack


func _ready():
	# load options
	var savefile = File.new()
	savefile.open(ProjectSettings.get_setting("filesystem/saving/settings_path"), File.READ)
	var savedict = JSON.parse(savefile.get_as_text()).result
	savefile.close()
	
	if savedict["version"] == ProjectSettings.get_setting("application/config/version"):
		check_option_1.pressed = savedict["settings"]["Option 1"]
		check_option_2.pressed = savedict["settings"]["Option 2"]
		check_option_3.pressed = savedict["settings"]["Option 3"]
		check_option_4.pressed = savedict["settings"]["Option 4"]

func _on_ButtonBack_pressed():
	Debug.print("Back button pressed")
	back()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		back()

func back():
	# save options
	var savedict: Dictionary = {}
	savedict["version"] = ProjectSettings.get_setting("application/config/version")
	savedict["settings"] = {
		"Option 1": check_option_1.pressed,
		"Option 2": check_option_2.pressed,
		"Option 3": check_option_3.pressed,
		"Option 4": check_option_4.pressed,
	}

	var savefile = File.new()
	savefile.open(ProjectSettings.get_setting("filesystem/saving/settings_path"), File.WRITE)
	savefile.store_string(JSON.print(savedict, "\t"))
	savefile.close()

	Debug.print("Settings saved to %s" % ProjectSettings.get_setting("filesystem/saving/settings_path"))

	# go to main menu
	var scene: PackedScene = load(back_scene_path)
	var _retval = get_tree().change_scene_to(scene)
