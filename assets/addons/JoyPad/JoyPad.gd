extends Control

export(String, "D-Pad", "JoyStick") var PadStyle
export var mapAnalogToDpad = true
export var visibleOnlyTouchscreen = true
export var AnalogTapToShow = false

func _ready(): reset()
func reset():
	$"leftPad/JoyStickLeft".mapAnalogToDpad = mapAnalogToDpad
	$"leftPad/JoyStickLeft".AnalogTapToShowContainer = get_parent()
	$"leftPad/JoyStickLeft".AnalogTapToShow = AnalogTapToShow
	
	var toEnable = "leftPad/DPad" if PadStyle=="D-Pad" else "leftPad/JoyStickLeft"
	var toDisable = "leftPad/JoyStickLeft" if PadStyle=="D-Pad" else "leftPad/DPad"
	enable_gamepad(toEnable)
	disable_gamepad(toDisable)
	
	if (visibleOnlyTouchscreen and not OS.has_touchscreen_ui_hint() or !visible):
		disable_gamepad("leftPad/DPad")
		disable_gamepad("leftPad/JoyStickLeft")

func enable_gamepad(node):
	get_node(node).visible = true
	get_node(node).position = Vector2(0, 0)
	
func disable_gamepad(node):
	get_node(node).visible = false
	get_node(node).position = Vector2(-1000, -1000)
