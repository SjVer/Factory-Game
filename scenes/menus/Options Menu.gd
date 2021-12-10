extends MarginContainer

## exports
export(String, FILE, "*.tscn") var back_scene_path

# buttons
onready var setting_Option1	: CheckBox 	= $Panel/Options/L/Option1
onready var setting_Option2	: CheckBox 	= $Panel/Options/L/Option2
onready var setting_Sound	: HSlider 	= $Panel/Options/L/Sound/Slider
onready var setting_Music	: HSlider 	= $Panel/Options/L/Music/Slider

# functions
func _ready():
	# set values according to current settings
	setting_Option1.pressed = Settings.option_1
	setting_Option2.pressed = Settings.option_2
	setting_Sound.value 	= Settings.sound
	setting_Music.value 	= Settings.music

func _on_Option1_set():		Settings.option_1 = setting_Option1.pressed
func _on_Option2_set():		Settings.option_2 = setting_Option2.pressed
func _on_Sound_set(value):
	Settings.sound = value
	AudioHandler.sound_volume = value
func _on_Music_set(value):
	Settings.music = value
	AudioHandler.music_volume = value
		
func _on_ButtonBack_pressed():
	back()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		back()

func back():
	# go to main menu
	Settings.save()

	var scene: PackedScene = load(TmpVars.take("back_scene_path") if TmpVars.has("back_scene_path") else back_scene_path)
	var _retval = get_tree().change_scene_to(scene)
