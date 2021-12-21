extends MarginContainer

## exports
export(String, FILE, "*.tscn") var back_scene_path

# buttons
onready var setting_GamePadStyle: OptionButton 	= $Panel/Options/L/GamePad/OptionButton
onready var setting_ShowGamepad	: CheckBox 		= $Panel/Options/L/ShowGamepad
onready var setting_Sound		: HSlider 		= $Panel/Options/L/Sound/Slider
onready var setting_Music		: HSlider 		= $Panel/Options/L/Music/Slider
onready var setting_Zoom		: HSlider 		= $Panel/Options/R/Zoom/Slider

# functions
func _ready():
	# set values according to current settings
	setting_GamePadStyle.selected 	= Settings.gamepad_style
	setting_ShowGamepad.pressed 	= Settings.show_gamepad
	setting_Sound.value 			= Settings.sound
	setting_Music.value 			= Settings.music
	setting_Zoom.value 				= Settings.zoom

func _on_OptionGamepadStyle_set(index):	Settings.gamepad_style = index
func _on_ShowGamepad_set():	Settings.show_gamepad = setting_ShowGamepad.pressed
func _on_Sound_set(value):
	Settings.sound = value
	AudioHandler.sound_volume = value
func _on_Music_set(value):
	Settings.music = value
	AudioHandler.music_volume = value
func _on_Zoom_set(value): Settings.zoom = value

# cancelling
func _on_ButtonBack_pressed():
	back()
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		back()
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		back()
func back():
	# go to main menu
	Settings.save()

	var scene: PackedScene = load(TmpVars.take("back_scene_path") if TmpVars.has("back_scene_path") else back_scene_path)
	var _retval = get_tree().change_scene_to(scene)
