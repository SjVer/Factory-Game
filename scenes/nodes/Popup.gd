tool
extends PopupDialog

export(String, MULTILINE) var text = "" setget set_text
export(bool) var allow_back_button = true

func set_text(new):
	text = new
	$VBoxContainer/Label.text = new

enum popupState { HIDDEN, PENDING, CONFIRMED, CANCELLED }
export(popupState) var state = popupState.HIDDEN setget state_setter
func state_setter(_new): state = popupState.HIDDEN

func _ready(): state = popupState.HIDDEN

func normal_popup():
	popup_centered_clamped(Vector2(400, 300), 0.750)

func _on_about_to_show(): state = popupState.PENDING

func _on_ButtonConfirm_pressed():
	state = popupState.CONFIRMED
	hide()
	
func _on_ButtonCancel_pressed():
	state = popupState.CANCELLED
	hide()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST and allow_back_button:
		_on_ButtonCancel_pressed()
